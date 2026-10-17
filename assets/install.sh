# Installation script for portable Julia with VS Code
# version 1.1 (C) 2022-2024, Petr Krysl

# Further configuration options for VS Code:
# {
#    "key": "ctrl+c",
#    "command": "workbench.action.terminal.copySelection",
#    "when": "terminalFocus && terminalProcessSupported && terminalTextSelected"
# },
# {
#    "key": "ctrl+v",
#    "command": "workbench.action.terminal.paste",
#    "when": "terminalFocus && terminalProcessSupported"
# },
# and make sure that this setting is an effect
# {
#     "terminal.integrated.allowChords": false
# }
# To set the window title:
# "window.title": "${activeEditorShort}${separator}${rootName}${separator}${profileName}${separator}focus:[${focusedView}]",

set -o errexit 
set -o nounset

# Julia installation will be handled by juliaup.
# Depot will be in standard place.

# Add the Git binary
export PATH="$(pwd)"/assets/PortableGit/bin:$PATH

# Now we install VS Code
if [ ! -x "$(pwd)"/assets/VSCode/Code ] ; then
    VSCodeVersion="VSCode.zip"
    if [ ! -d assets/VSCode ] ; then
        mkdir assets/VSCode
    fi
    if [ ! -f assets/"$VSCodeVersion" ] ; then
        echo "Downloading VSCode "
        curl "https://update.code.visualstudio.com/latest/win32-x64-archive/stable" --output assets/vscode.redirect
        download_link=$(cat assets/vscode.redirect | cut -d" " -f4)
        curl "$download_link" --output assets/"$VSCodeVersion"
    fi
    echo "Expanding $VSCodeVersion"
    unzip -q "assets/$VSCodeVersion" -d assets/VSCode
    # unzip -q "assets/data.zip" -d assets/
    # mv assets/data assets/VSCode
else
    echo "Found VSCode"
fi

# Install required/useful extensions
if [ ! -f assets/firsttimedone ] ; then
    if [ ! -d assets/VSCode/data ] ; then
	    mkdir assets/VSCode/data
    fi
    assets/VSCode/bin/code --install-extension alefragnani.Bookmarks --force
    assets/VSCode/bin/code --install-extension julialang.language-julia --force
    assets/VSCode/bin/code --install-extension kaiwood.center-editor-window --force
    assets/VSCode/bin/code --install-extension TroelsDamgaard.reflow-paragraph --force
    assets/VSCode/bin/code --install-extension yeannylam.recenter-top-bottom --force
    assets/VSCode/bin/code --install-extension nemesv.copy-file-name --force
    assets/VSCode/bin/code --install-extension PKief.material-icon-theme --force
    assets/VSCode/bin/code --install-extension johnpapa.vscode-peacock --force
    assets/VSCode/bin/code --install-extension chunsen.bracket-select --force
    assets/VSCode/bin/code --install-extension pokey.command-server --force
    assets/VSCode/bin/code --install-extension pokey.talon --force
    assets/VSCode/bin/code --install-extension sleistner.vscode-fileutils --force
    touch assets/firsttimedone
fi

# Make sure the vscode settings are set up to enable window titles
settings_file="assets/VSCode/data/user-data/User/settings.json"
if [ ! -f $settings_file ] ; then
        if [ ! -d `dirname $settings_file` ] ; then
                mkdir `dirname $settings_file`
        fi
        touch $settings_file
cat<<EOF >> $settings_file
{
    "terminal.integrated.commandsToSkipShell": [
        "language-julia.interrupt"
    ],
    "julia.symbolCacheDownload": true,
    "window.title": "\${activeEditorShort}\${separator}\${rootName}\${separator}\${profileName}\${separator}focus:[\${focusedView}]\${separator}lang:[\${activeEditorLanguageId}]",
}
EOF
fi

# Set up a shortcut with a good icon
t=$(realpath.exe ./DOUBLE_CLICK_ME.bat)
t=$(cygpath -w $t) 
s=VSCode.lnk
rm -f $s
echo "Creating shortcut $s to $t"
powershell.exe -Command "\$Shell = New-Object -ComObject WScript.Shell; \$Shortcut = \$Shell.CreateShortcut(\"$s\"); \$Shortcut.TargetPath = '$t'; \$Shortcut.IconLocation = 'assets\icons8-visual-studio-code-32.ico'; \$Shortcut.Save()" 
echo "The shortcut may be placed in %AppData%\Microsoft\Windows\Start Menu\Programs"

# Start VS Code
echo "Starting editor"
assets/VSCode/Code 
 

