# for as long as our tree isn't sane yet, prevent from having files
# installed into the live filesystem for non-sandbox people
export EDEST=${D}/fix/your/EDEST

# The linker in a prefixed system should look first in the prefix
# directories (search path), then the (host) system directories
OLDLDFLAGS=${LDFLAGS}
LDFLAGS=""
for dir in lib64 lib usr/lib64 usr/lib;
do
	dir=${EPREFIX}/${dir}
	[[ -d ${dir} ]] && \
		LDFLAGS="${LDFLAGS} -L${dir} -Wl,--rpath=${dir}"
done

##
## NOTE
##
# For GNU, IRIX and Sun linkers rpath can contain $ORIGIN, which is the
# path to the binary that runs it.  This allows to have relocatable
# packages, i.e. if you could set it up, any prefix would work.  It
# does, however, require to know where the binary is installed...

export LDFLAGS="${LDFLAGS} ${OLDLDFLAGS/${LDFLAGS}/}"

# The compiler in a prefixed system should look in the prefix header
# dirs.  The linker has the prefixed paths compiled in.
CPPFLAGS="-I${EPREFIX}/usr/include ${CPPFLAGS/-I${EPREFIX}\/usr\/include/}"
# configure can die if it detects a CPPFLAGS "change" due to suddenly
# noticing trailing space(s)
export CPPFLAGS=${CPPFLAGS%% }
