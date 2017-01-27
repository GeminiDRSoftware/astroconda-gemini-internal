.. _building_packages:

Generating Conda packages
*************************

Instructions for building internal packages (once everything is already set up)
are found in the sections :ref:`internal_builds` and :ref:`ci_builds`. If you
prefer, James can do the initial site setup, allowing you to get started
quickly and study the rest later.


Build prerequisites
===================

It is suggested that you use separate Anaconda installations for constructing
your /astro/iraf installation (only on primary build machines) and for building
packages. At GS, the latter installations are kept in /rtfproc on every build
machine::

  /rtfproc/anaconda2_4.2.0
           anaconda -> anaconda2_4.2.0

This separation avoids mixing an operational installation that needs to be
stable and well-controlled with a copy that is used for routine work and can
easily be replaced from scratch or updated when something goes wrong. Moreover,
at GS there is not enough disk space in our /astro/iraf partitions for many
intermediate build products anyway, so building in /rtfproc avoids running out
of space.


Install working copies of Anaconda
----------------------------------

This can be skipped if done previously. Note that the version doesn't have to
match the one used at run-time (though it's probably a good idea).

* Before building packages for the first time, you'll need to install Anaconda
  on each machine in the same way as for /astro/iraf:

    .. code-block:: sh

       bash Anaconda2-4.2.0-Linux-x86.sh -b -p /rtfproc/anaconda2_4.2.0

  (We could probably automate this a bit with Steuermann if needed, using the
  appropriate tarball for each architecture, but at GN there aren't many build
  machines anyway.)

* Create a symbolic link, for convenience and so the build wrappers know
  where to look:

    .. code-block:: sh

       cd /rtfproc
       ln -s anaconda2_4.2.0 anaconda

* The Conda channels to use for finding build dependencies should be defined
  :ref:`as in the installation procedure <conda_channels>` (a
  once-per-machine/user setup), if not done previously. From time to time, you
  may need to override these in the arguments of a given `conda-build` command,
  eg. if you want to force a dependency re-build (see `custom_channels`_).

  .. _custom_channels: http://conda.pydata.org/docs/custom-channels.html#test-custom-channels

* As of Anaconda 4.2.0, conda-build pads build environment paths to a length
  that doesn't work with IRAF (255 characters). Before you can build Gemini
  IRAF or other external packages, you'll need to change this to 70 characters,
  eg. as follows (or in your editor):

    .. code-block:: sh

       . /rtfproc/anaconda/bin/activate
       sed -i -e "s/\(DEFAULT_PREFIX_LENGTH[ \t]*=\).*/\1 70/" $(python -c "import conda_build; print conda_build.__path__[0]")/config.py

  See https://github.com/conda/conda-build/issues/1559.


Serving non-public source
-------------------------

This can be skipped if done previously, as long as the ``astroconda-source``
Web service is still running.

Most conda recipes obtain their source code from a public repository or tarball
URL, but that is not appropriate for IRAF & its external packages (which
contain proprietary source code such as Numerical Recipes) or for internal-only
package versions.

* IRAF itself lives in the Ureka repository (soon to be moved to github), which
  you must log into interactively, saving the password, one time only per
  machine/account before you can regenerate ``iraf`` or ``iraf-x11`` with
  conda-build (if you ever need to):

    .. code-block:: sh

       svn checkout --username jturner@gemini.edu https://aeon.stsci.edu/ssb/svn/u-rel/iraf-2.16/trunk iraf

* Our collection of IRAF package source tarballs from Ureka must be provided to
  conda-build via a Web service [#f_conda_build_567]_ running on a machine with
  the hostname alias ``astroconda-source``. This may seem a bit convoluted, but
  is transparent once set up (per site) and allows the build to work across
  Gemini & STScI sites without assuming that a shared NFS mount is available. A
  trivial Web server is available for this purpose in
  ``astroconda-iraf-helpers``:

    .. code-block:: sh

       git clone https://github.com/astroconda/astroconda-iraf-helpers.git
       ac_iraf_helpers=`pwd`/astroconda-iraf-helpers
       cd /rtfperm/ac_sources
       $ac_iraf_helpers/scripts/ac_source_server &

  This script would be best copied somewhere permanently and started via a cron
  job, so it isn't forgotten when the machine is restarted. The service runs on
  port 4440 (as it had been intended to use SSL, with a view to running a
  public master copy somewhere, but there isn't an obvious mechanism for
  keeping the password private).

* Internal Gemini package recipes (defined in this repository) also use the
  above ``astroconda-source`` service. This could be changed to use
  ``/rtfperm``, but should not be inconvenient if you are already building IRAF
  packages and would, say, allow STScI to build Gemini dev and test that their
  changes haven't broken our Python package.

.. [#f_conda_build_567] As recommended at
                        https://github.com/conda/conda-build/issues/567#issuecomment-245153550


.. _checkout_recipes:

Check out recipes to build
--------------------------

On your master build machine [#f_build_master]_, check out or update the
recipes that you want to build, eg.:

    .. code-block:: sh

       mkdir -p /astro/iraf/ac_build
       cd /astro/iraf/ac_build
       git clone https://github.com/jehturner/astroconda-gemini-internal.git

(The URLs for other recipe collections can be found under :ref:`recipe_maint`).

If you plan to do a continuous integration build for the Gemini packages, the
Steuermann job will then copy ``astroconda-gemini-internal`` from here to
``/rtfproc/ac_build`` on the other machines. Otherwise, you'll currently need
to make a copy on any additional machines yourself (with scp/rsync or git).
For non-CI builds, you may prefer to check out the recipes directly into
``/rtfproc/ac_build`` or somewhere else.

.. [#f_build_master] The build master is any machine you choose to co-ordinate
                     CI builds across the other machines. Its ssh key is
                     installed on each build machine, allowing it to access
                     them all non-interactively with ssh/scp. This should be a
                     high-availability machine, such as a VM, rather than one
                     that might be switched off, decommissioned or has no UPS.


Building general conda packages
===============================

Conda packages are defined in repositories containing one package recipe per
subdirectory. Each recipe includes a ``meta.yaml`` file, defining the package
name, version number, source code location etc. Most recipes also have a
``build.sh`` file, containing the commands used to build the package
(eg. ``python setup.py install``), as well as a dummy ``bld.bat`` for
Windows. There may also be patches or other supporting files used by
``build.sh``. A recipe is normally built by invoking ``conda-build`` with the
name of the recipe directory as its main argument (which also builds any
dependencies of that recipe that are defined in the same repository but not
already available as conda packages).

Files produced by the package build process are written to a ``conda-bld``
subdirectory of the Anaconda installation used, without modifying the
repository checkout in which build commands are executed. When successful, the
resulting conda packages are written to ``conda-bld/linux-64`` or
``conda-bld/osx-64``, as appropriate, which is essentially a conda channel
local to that Anaconda installation (and is picked up when doing ``conda
install --use-local``). If you copy packages from there into
``/rtfperm/ac_packages/public``, you'll need to run ``conda index`` on the
destination OS subdirectory afterwards.

.. warning::

   Our about-to-be-retired primary build machine with MacOS 10.6 is older
   than supported by Continuum, so many Python packages will not build there
   (this doesn't prevent building IRAF packages).

Information on maintaining conda packages is linked from :ref:`recipe_maint`.


.. _internal_builds:

Building Gemini internal packages
=================================

The internal Gemini package recipes in this repository are similar to their
public versions (where applicable), but use Jinja templating
(see `Templating with Jinja
<http://conda.pydata.org/docs/building/meta-yaml.html#templating-with-jinja>`_)
for dynamic versioning based on our established tags (dev, internal etc.).

The following scripts provide a wrapper interface that sets the appropriate
package version string and can be used to check out the corresponding source
from our internal repositories (including CVS, which is unsupported by
``conda-build``), initiate the build on the applicable machine and incorporate
the resulting package(s) into the local conda channel. These steps assume that
you have already checked out ``astroconda-gemini-internal`` as in
:ref:`checkout_recipes`.

In this example, the ``gemini`` meta-package recipe is used to build its
constituent packages in turn, but you could equally well specify
``iraf.gemini``, to build only that one.

* Ensure you're working in an up-to-date checkout of the recipe repo. (on
  each build machine):

    .. code-block:: sh

       cd /rtfproc/ac_build/astroconda-gemini-internal  # or wherever
       git pull                                         # (if needed)

* On one of your machines (normally the build master), check out the source for
  one or more internal packages (to ``/rtfperm/ac_sources``):

    .. code-block:: sh

       ./checkout --clean --tag dev gemini

* On each machine, build the package(s) as follows (this is pretty much
  ``conda-build`` with a couple of template variables defined):

    .. code-block:: sh

       ./build --tag dev gemini

* On each of your primary build machines (the ones used to generate packages
  for each architecture, ie. `linux-64` or `osx-64`), copy the resulting
  builds from Anaconda into the local conda channel (which at GS is mirrored to
  the external Web service) and re-index it:

    .. code-block:: sh

       ./distribute --tag dev gemini

.. note::

   If you need to run these commands around midnight, you can ensure
   consistency by setting DATE in the environment beforehand.

You can then install your new packages in a conda environment as described
:ref:`under "Installation Procedure" <install_env>`.

Note that conda IRAF package builds automatically verify whether the mkpkg
command succeeds, build help & apropos databases and take care of updating
extern.pkg, without you having to worry about those things separately. For
non-interactive use, success/failure is also propagated via the exit status of
the above scripts.


.. _ci_builds:

Continuous integration builds
=============================

Rather than building conda packages interactively, one machine at a time, you
can also initiate a distributed build across all the available machines at your
site, using STScI's continuous integration package, Steuermann. This checks out
the source, runs parallel test builds [#f_parallel]_ for each tag on every
machine (a total of up to 96 package/tag/OS combinations at GS) and collects
the resulting packages from the primary build machines into the conda
channel. A Web interface makes it easy to monitor progress and the final
status/logs of each job.

.. warning::

   This is currently not set up for GN (mostly a question of defining the
   relevant machines in a configuration file and installing an ssh key on
   each of them). There is no reason to duplicate the CI builds/testing across
   sites anyway, but this method might be more convenient for operational
   builds than repeating the same commands for multiple tags on multiple
   machines. Alternatively, you could forget this procedure and just install
   daily internal package builds from GS, falling back to the above interactive
   instructions when something needs changing.

.. warning::

   Until Gemini Python v2 is ready and the checkout scripts here have been
   updated to retrieve it from git, the build matrix currently packages
   non-functional gemini_python & gemaux versions for tags other than (the
   semi-functional) ``dev``. In the meantime, you may prefer to build only
   ``iraf.gemini``, interactively (or omit the Python packages from your
   subsequent install).

* First-time build control setup (from Ureka):

  Sorry this is currently a bit arcane and may need maintenance to continue
  working if STScI reorganizes things.

    .. code-block:: sh

       mkdir -p /astro/iraf/ac_build
       cd /astro/iraf/ac_build
       svn co https://aeon.stsci.edu/ssb/svn/u-rel/build/trunk ur_control
       export URWD=`pwd`/ur_control/sm_install
       cd ur_control/devtools
       . setup
       ./installpy      # Install a minimal Python environment
       ./installtools   # Install Steuermann, Pandokia etc. into it

* Preparatory checks:

  - Make sure you have enough space on each machine; clean out
    ``/rtfproc/anaconda/conda-bld`` if needed.

  - If you have just interrupted a previous ``multi_build`` attempt, make sure
    its jobs have finished or been killed on each machine [#f_multi_kill]_.

  - Make sure you don't have files (or a shell session) open in any directory
    that gets deleted/replaced by the build (this was more of an issue for
    Ureka, but would affect ``/rtfproc/ac_build/astroconda-gemini-internal``).

* Work in an up-to-date recipe check-out:

    .. code-block:: sh

       cd /astro/iraf/ac_build/astroconda-gemini-internal
       git pull

* Execute the build:

    .. code-block:: sh

       ./multi_build

* Monitor status:

    .. code-block:: sh

       firefox http://sbfrtf64re5:7070/steuermann_report.cgi?action=runs

  (substituting the name of your master build host.)

This process could be initiated by a cron job fairly easily, to provide daily
conda package builds for each tag in the internal `gemini` channel (see
:ref:`internal_pkg_inst`).

.. [#f_parallel] For peculiar licensing reasons, this actually runs IRAF builds
                 on 2 machines at a time (which is configurable).

.. [#f_multi_kill] I should get around to writing a distributed kill script
                   for this.

