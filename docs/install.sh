#!/bin/bash

exec </dev/tty
exec > >(tee -i archsetup.txt)
exec 2>&1

echo -ne "

Automated Arch Linux Installer

Verifying Arch Linux ISO is Booted
"
if [ ! -f /usr/bin/pacstrap ]; then
  echo "This script must be run from an Arch Linux ISO environment."
  exit 1
fi

root_check() {
  if [[ "$(id -u)" != "0" ]]; then
    echo -ne "ERROR! This script must be run under the 'root' user!\n"
    exit 1
  fi
}

docker_check() {
  if awk -F/ '$2 == "docker"' /proc/self/cgroup | read -r; then
    echo -ne "ERROR! Docker container is not supported (at the moment)\n"
    exit 1
  elif [[ -f /.dockerenv ]]; then
    echo -ne "ERROR! Docker container is not supported (at the moment)\n"
    exit 1
  fi
}

arch_check() {
  if [[ ! -e /etc/arch-release ]]; then
    echo -ne "ERROR! This script must be run in Arch Linux!\n"
    exit 1
  fi
}

pacman_check() {
  if [[ -f /var/lib/pacman/db.lck ]]; then
    echo "ERROR! Pacman is blocked."
    echo -ne "If not running remove /var/lib/pacman/db.lck.\n"
    exit 1
  fi
}

background_checks() {
  root_check
  arch_check
  pacman_check
  docker_check
}

select_option() {
  local options=("$@")
  local num_options=${#options[@]}
  local selected=0
  local last_selected=-1

  while true; do
    # Move cursor up to the start of the menu
    if [ $last_selected -ne -1 ]; then
      echo -ne "\033[${num_options}A"
    fi

    if [ $last_selected -eq -1 ]; then
      echo "Please select an option using the arrow keys and Enter:"
    fi
    for i in "${!options[@]}"; do
      if [ "$i" -eq $selected ]; then
        echo "> ${options[$i]}"
      else
        echo "  ${options[$i]}"
      fi
    done

    last_selected=$selected

    # Read user input
    read -rsn1 key
    case $key in
    $'\x1b') # ESC sequence
      read -rsn2 -t 0.1 key
      case $key in
      '[A') # Up arrow
        ((selected--))
        if [ $selected -lt 0 ]; then
          selected=$((num_options - 1))
        fi
        ;;
      '[B') # Down arrow
        ((selected++))
        if [ $selected -ge $num_options ]; then
          selected=0
        fi
        ;;
      esac
      ;;
    '') # Enter key
      break
      ;;
    esac
  done

  return $selected
}

# btrfs and ext4. Others will be added in future.
filesystem() {
  echo -ne "
    Please Select your file system for both boot and root
    "
  options=("btrfs" "ext4")
  select_option "${options[@]}"

  case $? in
  0) export FS=btrfs ;;
  1) export FS=ext4 ;;
  3) exit ;;
  *)
    echo "Wrong option please select again"
    filesystem
    ;;
  esac
}

# @description Detects and sets timezone.
timezone() {
  echo -ne "\nDetecting timezone automatically...\n"

  time_zone="$(curl -fs https://ipapi.co/timezone 2>/dev/null || true)"

  if [[ -n "$time_zone" && -f "/usr/share/zoneinfo/$time_zone" ]]; then
    echo -ne "\nSystem detected your timezone as: '$time_zone'\n"
    echo -ne "Is this correct?\n"

    options=("Yes" "No")
    select_option "${options[@]}"
    selection=$?

    case $selection in
    0)
      echo "$time_zone set as timezone"
      export TIMEZONE="$time_zone"
      return
      ;;
    1) ;;
    esac
  else
    echo "Automatic detection failed."
  fi

  # manual fallback
  while true; do
    echo -ne "\nEnter your desired timezone (example: Europe/London): "
    read -r new_timezone

    if [[ -f "/usr/share/zoneinfo/$new_timezone" ]]; then
      echo "$new_timezone set as timezone"
      export TIMEZONE="$new_timezone"
      break
    else
      echo "Invalid timezone. Please try again."
    fi
  done
}
# @description Set user's keyboard mapping.
keymap() {
  echo -ne "
    Please select key board layout from this list"
  options=(us by ca cf cz de dk es et fa fi fr gr hu il it lt lv mk nl no pl ro ru se sg ua uk)

  select_option "${options[@]}"
  keymap=${options[$?]}

  echo -ne "Your key boards layout: ${keymap} \n"
  export KEYMAP=$keymap
}

# @description Choose whether drive is SSD or not.
drivessd() {
  echo -ne "
    Is this a solid state, flash, or hard drive?
    "
  options=("SSD" "MMC" "HDD")
  select_option "${options[@]}"

  case $? in
  0)
    export MOUNT_OPTIONS="noatime,compress=zstd,ssd,commit=120"
    ;;
  1)
    export MOUNT_OPTIONS="noatime,compress=zstd:5,ssd,commit=120"
    ;;
  2)
    export MOUNT_OPTIONS="noatime,compress=zstd,commit=120"
    ;;
  *)
    echo "Wrong option. Try again"
    drivessd
    ;;
  esac
}

# @description Disk selection for drive to be used with installation.
diskpart() {
  echo -ne "
    THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK
    Please make sure you know what you are doing because
    after formatting your disk there is no way to get data back
    *****BACKUP YOUR DATA BEFORE CONTINUING*****
    ***I AM NOT RESPONSIBLE FOR ANY DATA LOSS***
"

  #Loop through selection if non-viable device (mmcblkXbootY, mmcblkXrpbm, etc) is selected
  while true; do
    PS3='
       Select the disk to install on: '
    mapfile -t options < <(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}')

    select_option "${options[@]}"
    disk=${options[$?]%|*}
    if [[ ! "${disk%|*}" =~ ^/dev/mmcblk[0-9]+[a-z]+[0-9]? ]]; then
      break
    fi
    echo -e "\n${disk%|*} is not a viable install drive \n"
  done

  echo -e "\n${disk%|*} selected \n"
  export DISK=${disk%|*}

  drivessd
}

# @description Gather username and password to be used for installation.
userinfo() {
  # Loop through user input until the user gives a valid username
  while true; do
    read -r -p "Please enter username: " username
    if [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]; then
      break
    fi
    echo "Incorrect username."
  done
  export USERNAME=$username

  while true; do
    read -rs -p "Please enter password: " PASSWORD1
    echo -ne "\n"
    read -rs -p "Please re-enter password: " PASSWORD2
    echo -ne "\n"
    if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
      break
    else
      echo -ne "ERROR! Passwords do not match. \n"
    fi
  done
  export PASSWORD=$PASSWORD1

  # Loop through user input until the user gives a valid hostname, but allow the user to force save
  while true; do
    read -r -p "Please name your machine: " name_of_machine
    # hostname regex (!!couldn't find spec for computer name!!)
    if [[ "${name_of_machine,,}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]; then
      break
    fi
    # if validation fails allow the user to force saving of the hostname
    read -r -p "Hostname doesn't seem correct. Do you still want to save it? (y/n)" force
    if [[ "${force,,}" = "y" ]]; then
      break
    fi
  done
  export NAME_OF_MACHINE=$name_of_machine
}

# Starting functions
background_checks
clear
userinfo
clear
diskpart
clear
filesystem
clear
timezone
clear
keymap

echo "Setting up mirrors for optimal download"
iso=$(curl -4 -fs --max-time 10 ifconfig.io/country_code || true)
timedatectl set-ntp true
pacman -Syy --noconfirm
pacman -Sy --noconfirm archlinux-keyring
pacman-key --init
pacman-key --populate archlinux
pacman -S --noconfirm --needed pacman-contrib terminus-font
setfont ter-v18b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
echo -ne "
Setting up $iso mirrors for faster downloads
"
if [[ -n "$iso" ]]; then
  reflector --country "$iso" --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
else
  reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
fi
pacman -Syy --noconfirm
if [[ $(grep -c "Server =" /etc/pacman.d/mirrorlist) -lt 5 ]]; then #check if there are less than 5 mirrors
  cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist
fi

if [ ! -d "/mnt" ]; then
  mkdir /mnt
fi
echo -ne "
Installing Prerequisites
"
pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc
echo -ne "
Formatting Disk
"
umount -A --recursive /mnt # make sure everything is unmounted before we start
# disk prep
sgdisk -Z "${DISK}"         # zap all on disk
sgdisk -a 2048 -o "${DISK}" # new gpt disk 2048 alignment

# create partitions depending on boot mode
if [[ -d /sys/firmware/efi ]]; then
  # UEFI system → only EFI + root
  sgdisk -n 1::+1GiB --typecode=1:ef00 --change-name=1:'EFIBOOT' "${DISK}"
  sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:'ROOT' "${DISK}"
else
  # BIOS system → BIOSBOOT + root
  sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' "${DISK}"
  sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:'ROOT' "${DISK}"
fi

if [[ "${DISK}" =~ nvme|mmcblk ]]; then
  P1=${DISK}p1
  P2=${DISK}p2
else
  P1=${DISK}1
  P2=${DISK}2
fi

if [[ -d /sys/firmware/efi ]]; then
  EFI_PART=$P1
  ROOT_PART=$P2
else
  BIOS_PART=$P1
  ROOT_PART=$P2
fi

# make filesystems
echo -ne "
Creating Filesystems
"

if [[ "${FS}" == "btrfs" ]]; then
  mkfs.btrfs -f "${ROOT_PART}"
  mount "${ROOT_PART}" /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@var_log
  btrfs subvolume create /mnt/@var_cache_pacman_pkg
  btrfs subvolume create /mnt/@snapshots
  umount /mnt
  mount -o ${MOUNT_OPTIONS},subvol=@ "${ROOT_PART}" /mnt
  mkdir -p /mnt/{home,.snapshots,var/log,var/cache/pacman/pkg}
  mount -o ${MOUNT_OPTIONS},subvol=@home "${ROOT_PART}" /mnt/home
  mount -o ${MOUNT_OPTIONS},subvol=@snapshots "${ROOT_PART}" /mnt/.snapshots
  mount -o ${MOUNT_OPTIONS},subvol=@var_log "${ROOT_PART}" /mnt/var/log
  mount -o ${MOUNT_OPTIONS},subvol=@var_cache_pacman_pkg "${ROOT_PART}" /mnt/var/cache/pacman/pkg
elif [[ "${FS}" == "ext4" ]]; then
  mkfs.ext4 -F "${ROOT_PART}"
  mount "${ROOT_PART}" /mnt
fi

if [[ -d /sys/firmware/efi ]]; then
  mkfs.fat -F32 "${EFI_PART}"
  mkdir -p /mnt/boot
  mount "${EFI_PART}" /mnt/boot
fi

if ! grep -qs '/mnt' /proc/mounts; then
  echo "Drive is not mounted can not continue"
  echo "Rebooting in 3 Seconds ..." && sleep 1
  echo "Rebooting in 2 Seconds ..." && sleep 1
  echo "Rebooting in 1 Second ..." && sleep 1
  reboot now
fi

echo -ne "
Arch Install on Main Drive
"
if [[ ! -d "/sys/firmware/efi" ]]; then
  pacstrap /mnt base base-devel linux-lts linux-firmware nano --noconfirm --needed
else
  pacstrap /mnt base base-devel linux-lts linux-firmware efibootmgr nano --noconfirm --needed
fi
echo "keyserver hkp://keyserver.ubuntu.com" >>/mnt/etc/pacman.d/gnupg/gpg.conf
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

genfstab -U /mnt >>/mnt/etc/fstab
echo "
  Generated /etc/fstab:
"
cat /mnt/etc/fstab
echo -ne "
Checking for low memory systems <8G
"
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[ $TOTAL_MEM -lt 8000000 ]]; then
  # Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
  mkdir -p /mnt/opt/swap # make a dir that we can apply NOCOW to to make it btrfs-friendly.
  if findmnt -n -o FSTYPE /mnt | grep -q btrfs; then
    chattr +C /mnt/opt/swap # apply NOCOW, btrfs needs that.
  fi
  dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
  chmod 600 /mnt/opt/swap/swapfile # set permissions.
  chown root /mnt/opt/swap/swapfile
  mkswap /mnt/opt/swap/swapfile
  swapon /mnt/opt/swap/swapfile
  echo "/opt/swap/swapfile    none    swap    sw    0    0" >>/mnt/etc/fstab # Add swap to fstab, so it KEEPS working after installation.
fi

gpu_type=$(lspci | grep -E "VGA|3D|Display")

# Console keymap -> X11 layout (they differ for a few entries).
# SDDM and dwm use the X11 layout, not the console keymap.
case "${KEYMAP}" in
uk) XKB_LAYOUT=gb XKB_VARIANT="" ;;
cf) XKB_LAYOUT=ca XKB_VARIANT=fr ;;
et) XKB_LAYOUT=ee XKB_VARIANT="" ;;
fa) XKB_LAYOUT=ir XKB_VARIANT="" ;;
sg) XKB_LAYOUT=ch XKB_VARIANT="" ;;
*) XKB_LAYOUT="${KEYMAP}" XKB_VARIANT="" ;;
esac

# NOTE: the heredoc delimiter is quoted ('EOF'), so nothing below is expanded
# by the live ISO shell. Everything is expanded inside the chroot, and values
# arrive through the environment. This keeps passwords with $ ` " \ intact.
arch-chroot /mnt /usr/bin/env \
  DISK="${DISK}" \
  FS="${FS}" \
  KEYMAP="${KEYMAP}" \
  XKB_LAYOUT="${XKB_LAYOUT}" \
  XKB_VARIANT="${XKB_VARIANT}" \
  TIMEZONE="${TIMEZONE}" \
  USERNAME="${USERNAME}" \
  PASSWORD="${PASSWORD}" \
  NAME_OF_MACHINE="${NAME_OF_MACHINE}" \
  GPU_TYPE="${gpu_type}" \
  bash <<'EOF'

echo -ne "
Network Setup
"
pacman -S --noconfirm --needed networkmanager
systemctl enable NetworkManager.service

echo -ne "
Installing base tools
"
pacman -S --noconfirm --needed pacman-contrib curl terminus-font reflector rsync grub arch-install-scripts git wget nano
if [[ "${FS}" == "btrfs" ]]; then
  pacman -S --noconfirm --needed btrfs-progs
fi

nc=$(nproc)
echo -ne "
You have ${nc} cores. Changing makeflags and compression settings.
"
TOTAL_MEM=$(grep -i 'memtotal' /proc/meminfo | grep -o '[[:digit:]]*')
if [[ $TOTAL_MEM -gt 8000000 ]]; then
  sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j${nc}\"/g" /etc/makepkg.conf
  sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T ${nc} -z -)/g" /etc/makepkg.conf
fi

echo -ne "
Setup language, locale and timezone
"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
# timedatectl/localectl do not work inside a chroot (no running systemd),
# so write the config files directly.
echo "LANG=en_US.UTF-8" >/etc/locale.conf
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc

# Console keymap (tty)
echo "KEYMAP=${KEYMAP}" >/etc/vconsole.conf
echo "Console keymap set to: ${KEYMAP}"

# X11 keymap (SDDM greeter + dwm session)
mkdir -p /etc/X11/xorg.conf.d
cat >/etc/X11/xorg.conf.d/00-keyboard.conf <<XKB
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "${XKB_LAYOUT}"
    Option "XkbVariant" "${XKB_VARIANT}"
EndSection
XKB
echo "X11 layout set to: ${XKB_LAYOUT} ${XKB_VARIANT}"

# pacman: parallel downloads, colors, easter egg, multilib
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Syy --noconfirm

echo -ne "
Installing Microcode
"
if grep -q "GenuineIntel" /proc/cpuinfo; then
  echo "Installing Intel microcode"
  pacman -S --noconfirm --needed intel-ucode
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
  echo "Installing AMD microcode"
  pacman -S --noconfirm --needed amd-ucode
else
  echo "Unable to determine CPU vendor. Skipping microcode installation."
fi

echo -ne "
Installing Graphics Drivers
"
# mesa is the baseline for X11 on everything (also covers VMs via modesetting).
# The vendor checks are independent ifs, so hybrid laptops get both drivers.
pacman -S --noconfirm --needed mesa lib32-mesa
if echo "${GPU_TYPE}" | grep -qiE "NVIDIA|GeForce"; then
  echo "Installing NVIDIA drivers: nvidia-lts"
  pacman -S --noconfirm --needed nvidia-lts nvidia-utils lib32-nvidia-utils
fi
if echo "${GPU_TYPE}" | grep -qiE "Radeon|AMD|ATI"; then
  echo "Installing AMD drivers"
  pacman -S --noconfirm --needed vulkan-radeon lib32-vulkan-radeon
fi
if echo "${GPU_TYPE}" | grep -qi "Intel"; then
  echo "Installing Intel drivers"
  pacman -S --noconfirm --needed vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver libva-utils libvdpau-va-gl
fi

echo -ne "
Adding User
"
groupadd -f libvirt
useradd -m -G wheel,video,libvirt -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "$USERNAME created (groups: wheel, video, libvirt), password set"
echo "$NAME_OF_MACHINE" >/etc/hostname
cat >/etc/hosts <<HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${NAME_OF_MACHINE}.localdomain ${NAME_OF_MACHINE}
HOSTS

# sudo for wheel (password required)
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo -ne "
Cloning arch-setup repository
"
su - "$USERNAME" -c 'cd ~ && git clone https://github.com/wattox00/arch-setup && chmod +x arch-setup/dwm-wattox.sh'

echo -ne "
Installing GRUB Bootloader
"
if [[ -d "/sys/firmware/efi" ]]; then
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
  grub-install --target=i386-pc "${DISK}"
fi

echo -ne "
Creating Grub Boot Menu
"
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "All set!"

echo -ne "
Enabling Essential Services
"
# systemd-timesyncd replaces ntp: no extra package, and `ntpd -qg` cannot
# work reliably inside a chroot anyway.
systemctl enable systemd-timesyncd.service
systemctl enable reflector.timer
systemctl enable fstrim.timer
echo "  NetworkManager, timesyncd, reflector and fstrim enabled"
EOF
