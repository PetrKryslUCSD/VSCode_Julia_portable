# VSCode_Julia_portable

TLDR: Portable Julia running in VSCode. 

The user’s system does not need to have Git installed: the portable version of
it is included. All the user needs to do is to double-click a batch file
(`DOUBLE_CLICK_ME.bat`): everything installs itself, and VS code pops up
preconfigured for work with Julia. A [tutorial Julia package](https://github.com/PetrKryslUCSD/JuliaTutorial) is installed, and opened when
the editor comes up. The subfolder `src` holds the source of the tutorial in
the file `tutorial_source.jl`. The tutorial can provide bits of code and
information in arbitrary order, or start at the top and execute the lines one
by one.

Tested on Windows 10 64-bit systems.
