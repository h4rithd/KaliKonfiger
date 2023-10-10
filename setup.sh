#!/bin/bash

# Define color escape codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

banner(){    
    echo ""
    echo " _      __    _     _   _     ___   _      ____  _   __    ____  ___  ";
    echo "| |_/  / /\  | |   | | | |_/ / / \ | |\ | | |_  | | / /\`_ | |_  | |_) ";
    echo "|_| \ /_/--\ |_|__ |_| |_| \ \_\_/ |_| \| |_|   |_| \_\_/ |_|__ |_| \ ";
    echo ""
    echo -e "${RED} Automate Kali Linux Setup and Configuration | by h4rithd.com${NC}"
    echo ""
    
}
# Function to install tools and check if a tool is installed
install_tools() {
    echo -e "${GREEN}[+] Installing tools....${NC}"

    echo -e "${GRAY}[!] Updating system....${NC}"
    sudo apt-get update > /dev/null 2>&1
    
    # List of tools to install
    tools_to_install=(
        xfce4-panel-profiles
        zsh
        gdb
        zsh-syntax-highlighting
        zsh-autosuggestions
        tmux
        mate-terminal
        dconf-cli
        gedit
        source-highlight
        fzf
        grc
        wmctrl
        dirsearch
        seclists
        ncdu
        bat
        remmina
        dbeaver
        2to3
        chisel
        python3-autopep8
        python3-dulwich
        feroxbuster
        emboss
        jq
        golang
        bloodhound
        xclip
    )

    total_tools="${#tools_to_install[@]}"
    installed_tools=0

    # Ctrl+C handler
    trap 'echo -e "${BLUE}[-] Installation aborted by user.${NC}"; exit 1' INT

    for tool in "${tools_to_install[@]}"; do
        if dpkg -l | awk '{print $2}' | grep -q "^$tool$"; then
            echo -e "${BLUE}[!] $tool is already installed.${NC}"
        else
            echo -e "${GRAY}[${installed_tools}/${total_tools}] Installing $tool...${NC}"
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$tool" -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"> /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}[+] $tool is installed successfully!${NC}"
            else
                echo -e "${RED}[-] Unable to install $tool, please try again.${NC}"
            fi
        fi
        installed_tools=$((installed_tools + 1))
    done

    # Setup zsh as default
    sudo chsh -s $(which zsh)
    chsh -s $(which zsh)

    echo -e "${GREEN}[100%] All tools installed.${NC}\n"
}

setup_xfce_settings(){
    echo -e "${GREEN}[+] Installing theme....${NC}"

    # Define destination directory
    THEME_DIR="/usr/share/backgrounds/h4rithd/"
    sudo mkdir -p "$THEME_DIR"

    # Copy wallpaper and lockscreen images
    sudo cp "$PWD/files/config/user/theme/wallpaper.jpg" "$THEME_DIR"
    sudo cp "$PWD/files/config/system/gtk-greeter/lockscreen-16x10.png" "$THEME_DIR/lockscreen-16x10.png"
    sudo chmod 644 "$THEME_DIR"/*

    # Backup the existing lightdm-gtk-greeter.conf file and Copy the custom lightdm-gtk-greeter.conf
    sudo cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
    sudo cp "$PWD/files/config/system/gtk-greeter/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf

    # setup xfce4 configuration files
    echo -e "${BLUE}[!] Setup xfce4 settings....${NC}"
    rsync -vaq "$PWD/files/config/user/theme/xfce4" "$HOME/.config/"
    find "$HOME/.config/xfce4" -type f -exec sed -i "s/ch4ng3_m3/$USER/g" {} \;
    xfce4-panel-profiles load "$PWD/files/config/user/theme/xfce4-profile"
    echo -e "${GRAY}[!] xfce4 setup complete.${NC}"

    # setup terminal settings
    echo -e "${GREEN}[+] Setting up terminal....${NC}"
    dconf write /org/mate/terminal/global/profile-list "['default', 'h4rithd']"
    dconf load /org/mate/terminal/profiles/ < "$PWD/files/config/system/dconf/mate-profile.ini"
    dconf write /org/mate/terminal/global/default-profile "'h4rithd'"
    echo -e "${GRAY}[!] Terminal setup complete.${NC}"

    # setup dotfiles
    echo -e "${GREEN}[+] Setting up dotfiles....${NC}"
    rm -rf /dev/shm/*
    git clone --quiet https://github.com/h4rithd/dotfiles /dev/shm/dotfiles
    rm -rf "$HOME/.cuirlrc" "$HOME/.hushlogin" "$HOME/.tmux.conf" "$HOME/.vimrc" "$HOME/.zshrc" "$HOME/.vim"
    cp -rf /dev/shm/dotfiles/.* "$HOME/"

    # Clone and install Vim plugins
    echo -e "${GRAY}[!] Installing vim plugins.${NC}"
    mkdir -p "$HOME/.vim/pack/plugins/opt"
    git clone --quiet https://github.com/joshdick/onedark.vim.git "$HOME/.vim/pack/plugins/opt/onedark.vim"
    echo -e "${BLUE}[!] onedark is installed successfully!.${NC}"
    git clone --quiet https://github.com/itchyny/lightline.vim "$HOME/.vim/pack/plugins/start/lightline"
    echo -e "${BLUE}[!] lightline is installed successfully!.${NC}"
    git clone --quiet --depth 1 https://github.com/sheerun/vim-polyglot "$HOME/.vim/pack/plugins/start/vim-polyglot"
    echo -e "${BLUE}[!] vim-polyglot is installed successfully!.${NC}"
    git clone --quiet https://github.com/preservim/nerdtree.git "$HOME/.vim/pack/vendor/start/nerdtree"
    echo -e "${BLUE}[!] nerdtree is installed successfully!.${NC}"
    vim -u NONE -c "helptags $HOME/.vim/pack/vendor/start/nerdtree/doc" -c q
    git clone --quiet https://github.com/andymass/vim-matchup.git "$HOME/.vim/pack/vendor/start/vim-matchup"
    echo -e "${BLUE}[!] vim-matchup is installed successfully!.${NC}"
    git clone --quiet https://github.com/mhinz/vim-startify.git "$HOME/.vim/pack/vendor/start/vim-startify"
    echo -e "${BLUE}[!] vim-startify is installed successfully!.${NC}"
    git clone --quiet --depth 1 https://github.com/lifepillar/vim-mucomplete.git "$HOME/.vim/pack/bundle/start/vim-mucomplete"
    echo -e "${BLUE}[!] vim-mucomplete is installed successfully!.${NC}"
    echo -e "${GRAY}[!] vim plugins setup complete.${NC}"
    echo -e "${GREEN}[!] Dotfiles setup complete.${NC}\n"
}

setup_gdbplugs() {
    echo -e "${GREEN}[+] Setting up GDB plugins....${NC}"
    # Create a directory for GDB plugins
    mkdir -p "$HOME/.gdb-plugins"
    
    # Clone and set up pwndbg and execute setup
    git clone --quiet https://github.com/pwndbg/pwndbg "$HOME/.gdb-plugins/pwndbg"
    $HOME/.gdb-plugins/pwndbg/setup.sh
    git clone --quiet https://github.com/longld/peda.git "$HOME/.gdb-plugins/peda"
    git clone --quiet https://github.com/alset0326/peda-arm.git "$HOME/.gdb-plugins/peda-arm"
    wget -q -O "$HOME/.gdb-plugins/.gdbinit-gef.py" https://github.com/hugsy/gef/raw/master/gef.py
    cp "$PWD/files/config/user/gdb/gdbinit" "$HOME/.gdbinit"
    
    # Move GDB plugin executables to /usr/bin (you may want to ensure they don't already exist)
    sudo cp -rf "$PWD/files/config/user/gdb/gdb-peda-arm" /usr/bin/gdb-peda-arm
    sudo cp -rf "$PWD/files/config/user/gdb/gdb-peda" /usr/bin/gdb-peda
    sudo cp -rf "$PWD/files/config/user/gdb/gdb-peda-intel" /usr/bin/gdb-peda-intel
    sudo cp -rf "$PWD/files/config/user/gdb/gdb-pwndbg" /usr/bin/gdb-pwndbg
    sudo cp -rf "$PWD/files/config/user/gdb/gdb-gef" /usr/bin/gdb-gef
    
    # Ensure the executables are executable
    sudo chmod +x /usr/bin/gdb-*
    echo -e "${GREEN}[!] GDB plugins setup complete.${NC}\n"
}

function install_extra_tools() {
    trap 'echo [-] Script interrupted by Ctrl+C"; exit 1' INT

    echo -e "${GREEN}[+] Setup external tools...${NC}"

    sudo chown -R $USER:$USER /opt/
    sudo rm -rf /tmp/*
    sudo rm -rf /opt/{adPEAS,AndroidRats,AutoRecon,AWSCloud,C2-Suite,deepce,droopescan,DS-Store,egressbuster,enum4linux-ng,GitTools,Gopherus,Invoke-Obfuscation,jdwp-shellifier,Jenkins,JNDI-Exploit-Kit,jwt_tool,LateralMovement,ligolo-ng,LinEnum,linux-exploit-suggester-2,linux-smart-enumeration,linWinPwn,microsoft,PowerShell-Suite,PowerSploit,rdkit,reverse-ssh,SharpShooter,SprayingToolkit,tplmap,username-anarchy,weevely3,WhatWaf,windapsearch,windows-kernel-exploits,ysoserial,KaliKonfiger}
    mkdir -p $HOME/.local/bin/
    mkdir -p /opt/{AndroidRats,AWSCloud,DS-Store,Jenkins,ysoserial,C2-Suite/{C2,Evasion/AtomPePacker},LateralMovement/{Linux/{Binarys,traitor,lxd},Windows/Binarys}}

    function clone_repo() {
        local repo_url="$1"
        local target_dir="$2"
        
        echo -e "${GRAY}[!] Cloning $repo_url..."
        git clone --quiet "$repo_url" "$target_dir"

        if [ $? -eq 0 ]; then
            echo -e "${BLUE}[+] Cloned $repo_url successfully!${NC}"
        else
            echo -e "${RED}[-] Unable to clone $repo_url, please try again!${NC}"
            exit 1
        fi
    }

    function install_tool() {
        local tool_name="$1"
        local tool_url="$2"
        local target_path="$3"

        echo -e "${GRAY}[!] Installing $tool_name...${NC}"
        curl -sL "$tool_url" -o "$target_path"
        chmod +x "$target_path"

        if [ $? -eq 0 ]; then
            echo -e "${BLUE}[!] Installed $tool_name successfully!${NC}"
        else
            echo -e "${RED}[-] Unable to install $tool_name, please try again!${NC}"
            exit 1
        fi
    }

    # Clone repositories
    clone_repo "https://github.com/61106960/adPEAS" "/opt/adPEAS"
    clone_repo "https://github.com/ScRiPt1337/Teardroid-phprat" "/opt/AndroidRats/Teardroid-phprat"
    clone_repo "https://github.com/Tib3rius/AutoRecon" "/opt/AutoRecon"
    clone_repo "https://github.com/stealthcopter/deepce" "/opt/deepce"
    clone_repo "https://github.com/SamJoan/droopescan" "/opt/droopescan"
    clone_repo "https://github.com/lijiejie/ds_store_exp" "/opt/DS-Store/ds_store_exp"
    clone_repo "https://github.com/gehaxelt/Python-dsstore" "/opt/DS-Store/Python-dsstore"
    clone_repo "https://github.com/trustedsec/egressbuster" "/opt/egressbuster"
    clone_repo "https://github.com/cddmp/enum4linux-ng" "/opt/enum4linux-ng"
    clone_repo "https://github.com/internetwache/GitTools" "/opt/GitTools"
    clone_repo "https://github.com/tarunkant/Gopherus" "/opt/Gopherus"
    clone_repo "https://github.com/gquere/pwn_jenkins" "/opt/Jenkins/pwn_jenkins"
    clone_repo "https://github.com/pimps/JNDI-Exploit-Kit" "/opt/JNDI-Exploit-Kit"
    clone_repo "https://github.com/danielbohannon/Invoke-Obfuscation" "/opt/Invoke-Obfuscation"
    clone_repo "https://github.com/IOActive/jdwp-shellifier" "/opt/jdwp-shellifier"
    clone_repo "https://github.com/ticarpi/jwt_tool" "/opt/jwt_tool"
    clone_repo "https://github.com/nicocha30/ligolo-ng" "/opt/ligolo-ng"
    clone_repo "https://github.com/rebootuser/LinEnum" "/opt/LinEnum"
    clone_repo "https://github.com/jondonas/linux-exploit-suggester-2" "/opt/linux-exploit-suggester-2"
    clone_repo "https://github.com/diego-treitos/linux-smart-enumeration" "/opt/linux-smart-enumeration"
    clone_repo "https://github.com/lefayjey/linWinPwn" "/opt/linWinPwn"
    clone_repo "https://github.com/frohoff/ysoserial" "/opt/ysoserial/ysoserial"
    clone_repo "https://github.com/pimps/ysoserial-modified" "/opt/ysoserial/ysoserial-modified"
    clone_repo "https://github.com/FuzzySecurity/PowerShell-Suite" "/opt/PowerShell-Suite"
    clone_repo "https://github.com/PowerShellMafia/PowerSploit" "/opt/PowerSploit"
    clone_repo "https://github.com/Fahrj/reverse-ssh" "/opt/reverse-ssh"
    clone_repo "https://github.com/rdkit/rdkit" "/opt/rdkit"
    clone_repo "https://github.com/mdsecactivebreach/SharpShooter" "/opt/SharpShooter"
    clone_repo "https://github.com/byt3bl33d3r/SprayingToolkit" "/opt/SprayingToolkit"
    clone_repo "https://github.com/epinna/tplmap" "/opt/tplmap"
    clone_repo "https://github.com/urbanadventurer/username-anarchy" "/opt/username-anarchy"
    clone_repo "https://github.com/epinna/weevely3" "/opt/weevely3"
    clone_repo "https://github.com/Ekultek/WhatWaf" "/opt/WhatWaf"
    clone_repo "https://github.com/ropnop/windapsearch" "/opt/windapsearch"
    clone_repo "https://github.com/SecWiki/windows-kernel-exploits" "/opt/windows-kernel-exploits"
    clone_repo "https://github.com/h4rithd/KaliKonfiger.git" "/opt/KaliKonfiger"

    # Install kerbrute
    curl -sL "$(curl -s https://api.github.com/repos/ropnop/kerbrute/releases/latest | jq -r ".assets[] | select(.name | endswith(\"linux_$(dpkg --print-architecture)\")).browser_download_url")" -o "$HOME/.local/bin/kerbrute"

    # Install kubeletctl
    curl -sL "$(curl -s https://api.github.com/repos/cyberark/kubeletctl/releases/latest | jq -r ".assets[] | select(.name | endswith(\"linux_$(dpkg --print-architecture)\")).browser_download_url")" -o "$HOME/.local/bin/kubeletctl"

    # Install AtomPePacker
    curl -sL "$(curl -s https://api.github.com/repos/NUL0x4C/AtomPePacker/releases/latest | jq -r '.assets[] | select(.name | endswith("Release.zip")).browser_download_url')" -o "/opt/C2-Suite/Evasion/AtomPePacker/Release.zip"
    unzip -P infected "/opt/C2-Suite/Evasion/AtomPePacker/Release.zip" -d "/opt/C2-Suite/Evasion/AtomPePacker"

    # Install Lateral Movement tools
    clone_repo "https://github.com/h4rithd/PrecompiledBinaries" "/tmp/PrecompiledBinaries"
    mv -f /tmp/PrecompiledBinaries/Linux/* "/opt/LateralMovement/Linux/Binarys/"
    mv -f /tmp/PrecompiledBinaries/* "/opt/LateralMovement/Windows/Binarys/"
    clone_repo "https://github.com/saghul/lxd-alpine-builder.git" "/opt/LateralMovement/Linux/lxd"

    clone_repo "https://github.com/samratashok/ADModule" "/opt/LateralMovement/Windows/ADModule"
    clone_repo "https://github.com/skelsec/pypykatz" "/opt/LateralMovement/Windows/pypykatz"
    clone_repo "https://github.com/pentestmonkey/windows-privesc-check" "/opt/LateralMovement/Windows/windows-privesc-check"
    clone_repo "https://github.com/bitsadmin/wesng" "/opt/LateralMovement/Windows/wesng"

    # Install traitor
    install_tool "traitor" "$(curl -s https://api.github.com/repos/liamg/traitor/releases/latest | jq -r '.assets[] | select(.name | endswith("traitor-386")).browser_download_url')" "/opt/LateralMovement/Linux/traitor/traitor-386"
    install_tool "traitor" "$(curl -s https://api.github.com/repos/liamg/traitor/releases/latest | jq -r '.assets[] | select(.name | endswith("traitor-386")).browser_download_url')" "/opt/LateralMovement/Linux/traitor/traitor-amd64"
    install_tool "traitor" "$(curl -s https://api.github.com/repos/liamg/traitor/releases/latest | jq -r '.assets[] | select(.name | endswith("traitor-386")).browser_download_url')" "/opt/LateralMovement/Linux/traitor/traitor-arm64"

    cp -rf $PWD/files/suite/LateralMovement/* /opt/LateralMovement/
    
    echo -e "${GREEN}[+] Setup complete.${NC}"
}

# Run the installation
banner
install_tools
setup_xfce_settings
install_extra_tools
setup_gdbplugs


