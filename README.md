NTFS to EXT4 Converter Script
Overview
This Bash script automates the process of converting a partition from NTFS to ext4 on a Fedora system. It is designed to be run in a safe environment (Fedora Live USB or rescue mode) to avoid errors related to mounted partitions.
Author: VazoniainaLicense: MITVersion: 1.0  
Features

Converts an NTFS partition to ext4 with safety checks.
Verifies the partition type and ensures it is not mounted.
Prompts for backup confirmation to prevent data loss.
Provides clear instructions for post-conversion steps (mounting, restoring data, updating /etc/fstab).

Prerequisites

A Fedora Live USB or rescue mode environment.
Root privileges (sudo).
Required tools: fdisk, mkfs.ext4, blkid, partprobe, lsblk (pre-installed on Fedora).
A backup of all data on the target partition.

Usage

Backup your data:

Copy all files from the target partition (e.g., /dev/sda4) to an external drive or another partition.


Boot into a safe environment:

Use a Fedora Live USB or enter rescue mode via GRUB:
At the GRUB menu, select your Fedora entry, press e, add rescue to the kernel line, and press Ctrl+X to boot.




Download and prepare the script:

Save the script as convert_ntfs_to_ext4.sh.
Make it executable:chmod +x convert_ntfs_to_ext4.sh




Run the script:

Execute with the target partition as an argument:sudo ./convert_ntfs_to_ext4.sh /dev/sda4


If no argument is provided, the script will prompt for the partition.
Follow the prompts to confirm backup and conversion.


Post-conversion:

Mount the new ext4 partition:sudo mkdir /mnt/ext4
sudo mount /dev/sda4 /mnt/ext4


Restore your backed-up data.
Optionally, update /etc/fstab for automatic mounting:echo "/dev/sda4 /mnt/ext4 ext4 defaults 0 2" | sudo tee -a /etc/fstab





Warnings

Data Loss: Converting a partition to ext4 will erase all data on it. Always back up your data first.
Correct Partition: Double-check the partition (e.g., /dev/sda4) to avoid modifying the wrong one. Use lsblk -f to verify.
Safe Environment: Do not run this script on a live system with mounted partitions, as it may fail or cause data loss.

Example
$ sudo ./convert_ntfs_to_ext4.sh /dev/sda4
Running in a safe environment (live USB or rescue mode).
WARNING: Converting /dev/sda4 to ext4 will ERASE ALL DATA on this partition!
Have you backed up all data on /dev/sda4? (y/N): y
Partition: /dev/sda4
Disk: /dev/sda
Start sector: 123456
End sector: 7890123
Proceed with converting /dev/sda4 to ext4? (y/N): y
Success: /dev/sda4 has been converted to ext4!

Troubleshooting

Error: "Disk in use": Ensure you are in a Live USB or rescue mode. Check with lsblk and swapon --show.
Partition not NTFS: Verify the partition type with lsblk -f.
Script fails: Share the error message and output of fdisk -l /dev/sda for assistance.

Contributing
Feel free to submit issues or pull requests to improve the script. Contact the author for suggestions or feedback.
License
This project is licensed under the MIT License. See the LICENSE file for details.
