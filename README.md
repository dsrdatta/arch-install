# Arch Linux Modular Installer

A minimal, modular, and script-driven Arch Linux installation system using sequential Bash scripts. This project is designed to automate the installation process while still allowing user input and control where needed (e.g. partitioning or microcode choice).


## 🖥️ How to Use

> ⚠️ **Warning:** This will erase all data on the selected drive. Use at your own risk.

1. **Boot into Arch ISO**
   - Recommended: Use the official Arch Linux ISO via USB or in a virtual machine.

2. **Download the installer and make scripts executable**

   ```bash
   git clone https://github.com/dsrdatta/arch-install
   cd arch-install
   chmod +x *.sh


3. **3. **Download the installer** 
    ```bash
    ./install.sh