General maintenance & further information
*****************************************


Anaconda installations
======================

For further information (eg. on removing packages and environments), see the
conda documentation here:

* Managing packages: http://conda.pydata.org/docs/using/pkgs.html.
* Managing environments: http://conda.pydata.org/docs/using/envs.html.


Astroconda
==========

The AstroConda documentation at https://astroconda.readthedocs.io covers
normal user installation, FAQs, how to contribute packages etc. This still
needs updating slightly for our new set of IRAF packages.

The most reliable way to see what packages are available in the AstroConda
channel(s) is to use ``conda info`` or load the URL in your browser.


Conda recipes
=============

The most potentially-interesting "recipe" definitions for building Anaconda
packages can be found in the following repositories:

* Main AstroConda recipe collection:
    https://github.com/astroconda/astroconda-contrib.

* AstroConda IRAF recipes (re-worked by James):
    https://github.com/astroconda/astroconda-iraf.

* Internal Gemini package recipes & documentation (for now):
    https://github.com/jehturner/astroconda-gemini-internal.

* Official recipe collection for free Anaconda packages:
    https://github.com/ContinuumIO/anaconda-recipes.

* Recipes for some optional, community-maintained packages:
    https://github.com/conda-forge.

* Open Astronomy Conda channel recipes:
    https://github.com/OpenAstronomy/conda-channel.

Each of recipe in turn obtains its source code from the package's original
repository or tarball, either directly from the corresponding URL or (mostly
for IRAF) using a local copy.


Building packages
=================

The main source of information on building conda packages is here:

  http://conda.pydata.org/docs/building/bpp.html

(the most useful sections being those on meta.yaml and environment variables).

Unfortunately, conda-build has some rather quirky limitations that can be
frustrating to resolve when writing new packages, but it is usually possible
with perserverance...

