#

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

# Select the version of julia to run
MyPortableJuliaMajorVersion=1.12
MyPortableJuliaMinorVersion=.6 # can be used to also select release candidate

MyPortableJulia=julia-$MyPortableJuliaMajorVersion$MyPortableJuliaMinorVersion

echo Julia version: $MyPortableJulia

# Make sure we are in the folder in which the portable Julia is installed.
if [ ! -d "$(pwd)"/assets/$MyPortableJulia ] ; then
    if [ ! -f "$(pwd)"/assets/$MyPortableJulia-win64.zip ] ; then
        echo "Downloading $MyPortableJulia"
        curl https://julialang-s3.julialang.org/bin/winnt/x64/$MyPortableJuliaMajorVersion/$MyPortableJulia-win64.zip --output "$(pwd)"/assets/$MyPortableJulia-win64.zip
    fi
    cd assets
    echo "Unzipping assets/$MyPortableJulia-win64.zip"
    unzip -q "$(pwd)"/$MyPortableJulia-win64.zip
    cd ..
else
    echo "Found $MyPortableJulia"
fi

# Locate the Julia depot in the current folder.
export MyDepot="$(pwd)"/assets/.$MyPortableJulia-depot
if [ ! -d "$MyDepot" ] ; then
    mkdir "$MyDepot"
else
    echo "Found depot $MyDepot"
fi
export JULIA_DEPOT_PATH="$MyDepot"

# We want to find executables in the julia depot
export PATH=$JULIA_DEPOT_PATH/bin:$PATH

# Make sure we can start Julia just by referring to the program name.
export PATH="$(pwd)"/assets/$MyPortableJulia/bin:$PATH

# Make sure we can start gnuplot just by referring to the program name.
# export PATH="$(pwd)"/assets/gnuplot/bin:$PATH

# Add the Git binary
export PATH="$(pwd)"/assets/PortableGit/bin:$PATH

# Make sure the Julia REPL when started activates/instantiates
if [ ! -f "$MyDepot"/config/startup.jl ] ; then
        if [ ! -d "$MyDepot"/config ] ; then
                mkdir "$MyDepot"/config
        fi
        touch "$MyDepot"/config/startup.jl
        # Make sure Revise, JuliaFormatter are present in the default environment
        julia -E 'import Pkg; Pkg.add("Revise")'
        julia -E 'import Pkg; Pkg.add("JuliaFormatter")'
cat<<EOF >> "$MyDepot/config/startup.jl"
using Pkg 
# Disable updating registry on add (still runs on up), as it is slow
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true
atreplinit() do repl
    try
        @eval using Revise
    catch err
        println("Error starting Revise: \$err")
    end
    try
        @eval using JuliaFormatter
    catch err
        println("Error starting JuliaFormatter: \$err")
    end
end
EOF
fi

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

# Make sure the Julia REPL when started activates/instantiates
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

# Start VS Code
echo "Starting editor"
assets/VSCode/Code 
