# PENDRIVE-TOOLS

 <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1 align="center">
        <img src="https://i.ibb.co/DgtTzwmC/Screenshot-2.png"/>
        <img src="https://i.ibb.co/nsFR4T4h/Captura-de-tela-de-2025-05-01-19-46-50.png"/>
    </h1>


 
 This is a simple Batch Script (CMD) tool using PowerShell for Windows and a Bash Script for Linux to format and verify the integrity of USB drives or storage devices connected to your computer.


 # FUNCTIONS
- Quick format in FAT32, NTFS, or exFAT
- Integrity check using `chkdsk` and status reporting via `PowerShell` (for Windows) and `fsck` (for Linux).
- User-friendly terminal interface with numbered menus
# USAGE
#### WINDOWS

- Download or clone this repository.
- Run the .bat file (it works without admin perms)
- Follow the interactive menu to select the language, choose your action, and pick the desired device.

#### LINUX
- Follow this step 
###### use nano to create the file or download it here
```
 nano pendrive_tools.sh
```
###### Grant execution permissions:
```
chmod +x pendrive_tools.sh
```
###### Run the Script with Proper Permissions
```
./pendrive_tools.sh
```
# Info
- Maybe i should add more functions soon, but for now it will be like that ;)
- edit 01/05/25: i added linux support :D, windows one need some fixes for later
- edit 11/05/25: fixed windows version now working, this time used diskpart


>[!WARNING]
>Formatting will erase all data on the selected drive.
>Make sure you select the correct device before proceeding.
