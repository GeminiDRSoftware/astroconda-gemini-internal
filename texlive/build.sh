# This must be run with TMPDIR=/rtfproc/tmp (for conda-build) on any machines
# where /tmp doesn't have 3GB free space to create the final tarball.

# Determine the appropriate target architecture for TeX:
target=binary_x86_64-$(uname -s | tr 'A-Z' 'a-z')

# Create a copy of an install profile file with its paths updated, since the
# installer isn't clever enough to expand $PREFIX as a variable. For now we
# just discard the normally-parallel texmf-local/ directory, which is empty
# until any site-wide modifications are added. Also update the profile with
# the target architecture: 
sed -e "s|\${PREFIX}|$PREFIX|g" -e "/^$target/s|[ \t]0[ \t]*$| 1|" \
    "$RECIPE_DIR"/texlive.profile > texlive.profile

# Use the texlive installer to download pre-built TeX packages, supplying
# answers to its questions via the profile:
./install-tl -profile texlive.profile

# The installer is asked to create symbolic links in $PREFIX/texlive/bin etc.,
# avoiding any special environment setup, but we have to delete any dangling
# links or else conda-build will fail to do its relocation stuff:
find $PREFIX -type l -exec test ! -e {} \; -exec rm -f {} \;

