# VSCode_Julia_portable

TLDR: Portable Julia running in VSCode. 

The user’s system does not need to have Git installed: the portable version of
it is included. All the user needs to do is to double-click a batch file
(`DOUBLE_CLICK_ME.bat`): everything installs itself, and VS code pops up
preconfigured for work with Julia. 

Tested on Windows 11 64-bit systems.

## Using IntelliSense for Julia in VSCode

We shall refer to "IntelliSense" as features including code completion,
parameter info, etc. enabled by the Language Server Protocol (`LanguageServer.jl`). 

### Package environment

As an example, here is the simplified tree of the package `FinetoolsAcoustics.jl`:

```
FinetoolsAcoustics.jl
    Project.toml
    README.md
    ...
    
+---docs
        ...
                
+---examples
        Manifest.toml
        Project.toml
        
    +---coupling
            sphsld_acous_coupl_examples.jl
            
    +---data
            data.zip
            
    +---modal
            Fahy_examples.jl
            ...
            
    +---steady_state
        +---2-d
                acou_annulus_examples.jl
                ...
                
        +---3-d
                baffled_piston_examples.jl
                ...
                
    +---transient
            baffled_piston_examples.jl
            ...
            
+---src
        AlgoAcoustModule.jl
        allmodules.jl
        FEMMAcoustModule.jl
        FEMMAcoustNICEModule.jl
        FEMMAcoustSurfModule.jl
        FinEtoolsAcoustics.jl
        MatAcoustFluidModule.jl
        
+---test
        runtests.jl
        test_acoustics.jl
        test_acoustics2.jl
        test_vibroacoustics.jl
        
+---tutorials
        baffled_piston_tut.jl
        ...
        Manifest.toml
        Project.toml
        ...
```      

#### Package source files

Activating the environment of the package `FinEtoolsAcoustics.jl` itself enables
the IntelliSense in the source files under the `src` directory. Without us doing
anything else, IntelliSense will not be available for the
`FinEtoolsAcoustics.jl` package in any of the other files, in particular those
under the `test`, `examples`, and `tutorials` folders. IntelliSense can be facilitated
in those files by following the steps below.

#### Test files

We support IntelliSense in the test files by using the following trick: the
source file at the top of the package, `FinEtoolsAcoustics.jl`, is equipped with
a "false-include" as

```julia
# Enable LSP look-up in test modules.
if false include("../test/runtests.jl") end
```

This immediately enables IntelliSense for the code in the package
`FinEtoolsAcoustics.jl` in all the test files listed in `runtests.jl`. Here for
instance `test_acoustics.jl`. Without this  "false-include", the functionality
in  the package `FinEtoolsAcoustics.jl` would not be visible to the LSP server,
and IntelliSense would not be provided for the symbols in that package (even
though it would work for other packages referenced in the package environment).

#### Example and tutorial files

The `examples` and the `tutorials` folders are separate environments (notice the
`Project.toml` files). The package `FinEtoolsAcoustics.jl` is added to this environment:

```
julia> using Pkg; Pkg.status();
Status `FinEtoolsAcoustics.jl\examples\Project.toml`
...
⌃ [72171760] FinEtoolsAcoustics v3.1.0
...
```

When we switch to this environment in VSCode,
IntelliSense for the code in the package `FinEtoolsAcoustics.jl` is enabled.
Without these separate environments, the functionality in  the package
`FinEtoolsAcoustics.jl` would not be visible to the LSP server, and IntelliSense
would not be provided for the symbols in that package (even though it would work
for other packages referenced in the package environment).


### Project environment with shared functionality in a package
 
As an example, here is a project which does its work using scripts (i.e. it is
not a "package"). Nevertheless, the functionality shared by the scripts is
encapsulated in a package (under the `src` folder, in the package file
`FRFPlots.jl`).

The structure of the package is shown in this tree.

```
FRFPlots.jl
    Manifest.toml
    Project.toml
    README.md
    
+---scripts
        discretization_errors.jl
        Manifest.toml
        model_errors.jl
        parameter_study.jl
        plot_experiments.jl
        Project.toml
        
+---src
        FRFPlots.jl
```

#### Script files

The scripts have their own environment (notice the `Project.toml` file). To use
the scripts, this environment is activated (the folder is opened in VSCode).
The package containing the shared functionality is `dev`ed in this environment:

```
julia> using Pkg; Pkg.status();
Status `FRFPlots.jl\scripts\Project.toml`
  ...
  [e897d28e] FRFPlots v0.1.0 `..`
  ...
```

This step enables IntelliSense in all the scripts. Note that if we were to put a
function in one of the script files and wanted to use it in another script,
that function would not be visible to the IntelliSense. 

### Project environment with function definitions scattered across scripts

I do not know how to make IntelliSense work for these scripts. This is not a very good way of using a programming language anyway. Best avoid that.

