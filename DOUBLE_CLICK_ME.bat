@echo off
IF EXIST .\assets\PortableGit (ECHO Found PortableGit
) ELSE (
    ECHO Downloading Git
    curl --location --request GET https://github.com/git-for-windows/git/releases/download/v2.36.0.windows.1/PortableGit-2.36.0-64-bit.7z.exe --output .\assets\PortableGit-2.36.0-64-bit.7z.exe
    ECHO Installing Git
    .\assets\PortableGit-2.36.0-64-bit.7z.exe -y -gm2 -o.\assets\PortableGit
)
.\assets\PortableGit\bin\bash -c ./assets/install.sh