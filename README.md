# ntfsToExt4Formater

> A Bash script to automate the conversion of an NTFS partition to ext4 on Fedora systems.

---

## 📑 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Warnings](#warnings)
- [Example](#example)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

---

## 🧭 Overview

The `ntfsToExt4Formater` script simplifies converting an NTFS partition to ext4 on Fedora. It includes safety checks to ensure the partition is valid and unmounted, prompts for user confirmation to prevent data loss, and provides clear post-conversion instructions.  
⚠️ **Run the script in a safe environment** (Fedora Live USB or rescue mode) to avoid errors related to mounted partitions.

---

## ✨ Features

- Converts NTFS to ext4 with automated partition management.
- Verifies partition type (NTFS) and ensures it is not mounted.
- Automatically retrieves partition details (start/end sectors).
- Prompts for backup confirmation to prevent accidental data loss.
- Provides post-conversion guidance (mounting, restoring data, updating `/etc/fstab`).
- Uses color-coded terminal output for clarity.
- Includes robust error handling.

---

## ⚙️ Prerequisites

- **Fedora Live USB or rescue mode**  
  Required to ensure the target disk is not in use.

- **Root privileges**  
  Must be run with `sudo` or as root.

- **Required tools**  
  `fdisk`, `mkfs.ext4`, `blkid`, `partprobe`, `lsblk` (usually pre-installed on Fedora).

- **Backup**  
  All data on the target partition must be backed up, as conversion erases it.

- **Target partition**  
  An NTFS partition (e.g., `/dev/sda4`) to convert.

---

## 📦 Installation

```bash
git clone https://github.com/FunnyVazoniaina/ntfsToExt4Formater.git
cd ntfsToExt4Formater
chmod +x convert_ntfs_to_ext4.sh
🚀 Usage
1. Backup your data
bash
Copy
Edit
sudo cp -r /mnt/ntfs/* /path/to/backup/
2. Boot into a safe environment
Fedora Live USB:

Create a Fedora Live USB (with Fedora Media Writer or dd)

Boot from USB and select Try Fedora

Rescue Mode:

At GRUB menu, select Fedora entry, press e, add rescue to kernel line, press Ctrl+X

3. Run the script
bash
Copy
Edit
sudo ./convert_ntfs_to_ext4.sh /dev/sda4
If no argument is provided, the script prompts for the partition

Confirm backup

Review partition details (disk, sectors)

Confirm to proceed

4. Post-conversion steps
bash
Copy
Edit
sudo mkdir /mnt/ext4
sudo mount /dev/sda4 /mnt/ext4

sudo cp -r /path/to/backup/* /mnt/ext4/

echo "/dev/sda4 /mnt/ext4 ext4 defaults 0 2" | sudo tee -a /etc/fstab
sudo mount -a
⚠️ Warnings
Data Loss: Converting to ext4 erases all data. Always back up before proceeding.

Correct Partition: Verify the partition (e.g., /dev/sda4) using lsblk -f.

Safe Environment: Run only from Fedora Live USB or rescue mode.

Root Access: Needed to modify partitions.

🧪 Example
bash
Copy
Edit
$ sudo ./convert_ntfs_to_ext4.sh /dev/sda4
Running in a safe environment (live USB or rescue mode).
WARNING: Converting /dev/sda4 to ext4 will ERASE ALL DATA on this partition!
Have you backed up all data on /dev/sda4? (y/N): y
Partition: /dev/sda4
Disk: /dev/sda
Start sector: 123456
End sector: 7890123
Proceed with converting /dev/sda4 to ext4? (y/N): y
Modifying partition table...
Formatting /dev/sda4 as ext4...
Success: /dev/sda4 has been converted to ext4!

Next steps:
1. Mount the partition:
   sudo mkdir /mnt/ext4
   sudo mount /dev/sda4 /mnt/ext4

2. Restore your backed-up data.

3. Update /etc/fstab if needed:
   /dev/sda4 /mnt/ext4 ext4 defaults 0 2

4. Reboot your system.
🛠️ Troubleshooting
🔸 "Disk in use" error:
Ensure you are in a Live USB or rescue mode.

Check mounted partitions:

bash
Copy
Edit
lsblk
df -h | grep /dev/sda
swapon --show
Unmount or disable swap:

bash
Copy
Edit
sudo umount /dev/sda4
sudo swapoff -a
🔸 Partition not NTFS
Check:

bash
Copy
Edit
lsblk -f
🔸 Script fails
Check the error message and output:

bash
Copy
Edit
sudo fdisk -l /dev/sda
🔸 Missing tools
Install required tools:

bash
Copy
Edit
sudo dnf install fdisk util-linux e2fsprogs
🤝 Contributing
Contributions are welcome!
To contribute:

bash
Copy
Edit
# Fork the repo and create a branch
git checkout -b feature/your-feature

# Make your changes and commit
git commit -m "Add your feature"

# Push to your fork
git push origin feature/your-feature
Then open a pull request.

Please report issues or improvements via GitHub Issues.

📄 License
This project is licensed under the MIT License.

👤 Author
Name: Vazoniaina

GitHub: FunnyVazoniaina