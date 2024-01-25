#

# Installation script for portable Julia with VS Code
# version 1.0 (C) 2022-2023, Petr Krysl
set -o errexit 
set -o nounset

# Select the version of julia to run
MyPortableJuliaMajorVersion=1.10
MyPortableJuliaMinorVersion=.0 # can be used to also select release candidate
MyPortableJulia=julia-$MyPortableJuliaMajorVersion$MyPortableJuliaMinorVersion

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

# Expand the other zip files
# if [ ! -d assets/gnuplot ] ; then
#     if [ ! -f ./assets/gnuplot.zip ] ; then
#         echo "Downloading gnuplot"
#         curl http://tmacchant33.starfree.jp/gnuplot_files/gp550-20220416-win64-mingw.zip --output ./assets/gnuplot.zip
#     fi
#     echo Installing gnuplot 
#     cd assets
#     unzip -q ./gnuplot.zip
#     cd ..
# fi

# Make sure we can start Julia just by referring to the program name.
export PATH="$(pwd)"/assets/$MyPortableJulia/bin:$PATH

# Make sure we can start gnuplot just by referring to the program name.
# export PATH="$(pwd)"/assets/gnuplot/bin:$PATH

# Add the Git binary
export PATH="$(pwd)"/assets/PortableGit/bin:$PATH

# Download, and instantiate the tutorial packages, in order to bring Julia depot up-to-date 
# if [ ! -d JuliaTutorial ] ; then
#     echo "Activating/instantiating a package"
#     for n in JuliaTutorial
#     do 
#         if [ ! -d $n ] ; then
#             echo "Activating and instantiating $n"
#             git clone https://github.com/PetrKryslUCSD/$n.git
#         fi
#         cd $n
#         julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile(); exit()'
#         cd ..
#     done
# fi

# Make sure the Julia REPL when started activates/instantiates
if [ ! -f "$MyDepot"/config/startup.jl ] ; then
        if [ ! -d "$MyDepot"/config ] ; then
                mkdir "$MyDepot"/config
        fi
        touch "$MyDepot"/config/startup.jl
cat<<EOF >> "$MyDepot/config/startup.jl"
using Pkg 
# Disable updating registry on add (still runs on up), as it is slow
Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true
if isfile("Project.toml") && isfile("Manifest.toml")
   Pkg.activate(".") 
   Pkg.instantiate()
end
import Pkg; Pkg.add("Revise")
# Setup Revise.jl
atreplinit() do repl
    try
        @eval using Revise
    catch err
        println("Error starting Revise \$err")
    end
end
# Better format for floats
using Printf 
Base.show(io::IO, f::Float64) = @printf(io, "%1.5e", f)
Base.show(io::IO, f::Float32) = @printf(io, "%1.5e", f)
Base.show(io::IO, f::Float16) = @printf(io, "%1.5e", f)
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

# Install required extensions
if [ ! -f assets/firsttimedone ] ; then
    mkdir assets/VSCode/data
    assets/VSCode/bin/code --install-extension alefragnani.Bookmarks --force
    assets/VSCode/bin/code --install-extension julialang.language-julia --force
    assets/VSCode/bin/code --install-extension kaiwood.center-editor-window --force
    assets/VSCode/bin/code --install-extension stkb.rewrap --force
    touch assets/firsttimedone
fi

# Start VS Code
echo "Starting editor"
assets/VSCode/Code 
