using BinaryBuilder

sources = ["./src"]

# There are more supported platforms available in BinaryBuilder
# (see supported_platforms()), but just build the most common ones.
platforms = [
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:armv7l, :glibc),
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# Libddierckx links to libgfortran, so we need to build specific to
# Libgfortran version (equivalently the gcc version)
platforms = expand_gcc_versions(platforms)

# some platforms don't work. :(
non_working_platforms = [
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc4))
]                     
platforms = setdiff(platforms, non_working_platforms)

script = raw"""
cd $WORKSPACE/srcdir/ddierckx

flags="-O3 -shared -fPIC"
libdir="lib"

# set suffix
if [[ ${target} == *-mingw32 ]]; then
    suffix="dll"
# flags="${flags} -static-libgfortran -static-libgcc"
    libdir="bin"
elif [[ ${target} == *apple* ]]; then
    suffix="dylib"
else
    suffix="so"
fi

mkdir -p $WORKSPACE/destdir/${libdir}
gfortran -o $WORKSPACE/destdir/${libdir}/libddierckx.${suffix} ${flags} *.f
"""

dependencies = []
products(prefix) = [LibraryProduct(prefix, "libddierckx", :libddierckx)]

build_tarballs(ARGS, "libddierckx", v"1.0.0", sources, script, platforms,
               products, dependencies)
