using Pkg

Pkg.instantiate()

using PackageCompiler

# fetch authentication token
const LIB_PATH = get(ENV, "LIB_PATH", "MorseAPI.so")

create_sysimage(:MorseAPI;
    sysimage_path=LIB_PATH,
    precompile_execution_file="deploy/precompile.jl")