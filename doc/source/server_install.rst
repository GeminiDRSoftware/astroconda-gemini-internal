Network server installation
***************************

As you might expect, this consists of installing AstroConda under /astro/iraf
on a Linux and an Apple build machine and synchronizing the two installations
[#f1]_ from there to the same paths on your Netapp server. For the purposes of
this section, it is assumed that the necessary packages have already been built
(otherwise see :ref:`building_packages`).

At GS, two primary build machines are used to build conda packages for
production use and construct the corresponding internal installations, while
several secondary build machines (running newer CentOS and MacOS versions) are
used for continuous integration, testing and rotation into the primary role.

.. note::
   Continuum doesn't really promote the free version of Anaconda for shared
   installations and there are one or two quirks to be aware of.

   Although individual packages are relocatable from their build paths,
   Anaconda doesn't support moving an existing installation, as Ureka did.

.. [#f1] (STScI does not provide 32-bit Linux builds.)


Suggested directory structure
=============================

Although it may look back to front at first glance, the test installation at
Gemini South is structured as follows::

   /astro/iraf/linux-64/anaconda2_4.2.0
                        anaconda -> anaconda2_4.2.0
                        dev -> anaconda2_4.2.0/envs/dev_20161214

   /astro/iraf/osx-64/anaconda2_4.2.0
                      anaconda -> anaconda2_4.2.0
                      dev -> anaconda2_4.2.0/envs/dev_20161214

Rationale:

* The path /astro/iraf/linux-64/anaconda is really an abbreviation for
  /astro/iraf/anaconda/linux-64/anaconda, but is shorter to type and I don't
  see much need for the extra top-level directory. The platform names are
  those used by Anaconda.

* Including the version number in the name of the main anaconda directory
  avoids ambiguity and allows transitional use of multiple versions, while the
  link "anaconda" makes it easy to reference the default version at any given
  time, without having to remember its number (or hard-wire it in a script).

* Symbolic links can be used by the maintainer to define which dated version of
  given environment name to use by default, eg. requesting ``dev`` without a
  date currently gives ``dev_2016121`` (which you can also request
  explicitly). The base/link names can be anything you like
  (eg. ``new_ccds``). The current ``gempython.sh`` script expects all the
  environments in ``envs/`` to be dated, something that we can make a bit more
  flexible.

* Links placed directly in ``anaconda/envs`` (eg. ``dev -> dev_20161214``) also
  work, but conda expects to manage these directories itself, so there is no
  guarantee that such a scheme would continue to work in future. Moreover,
  based on past experience, placing the links above the main anaconda directory
  allows different ones (eg. ``gsops`` and ``gsops_prev``) to point to
  different base Anaconda installations, simplifying the logistics of
  transitioning between old and new releases, without requiring special setup
  logic.

Although it would be a positive development if we can standardize the
appearance of the installation between our sites, the only code that actually
requires any of the above conventions is the ``gempython.sh`` setup script in
this repository.


Installation procedure
======================

This could be automated a bit, but is not unduly labourious and will only need
repeating fully maybe once a year (if our Anaconda version changes).

* Download and install the target 64-bit, Python 2.7 version of Anaconda under
  /astro/iraf on each of your primary build machines:

  .. code-block:: sh

     mkdir -p /astro/iraf/linux-64
     bash Anaconda2-4.2.0-Linux-x86.sh -b -p /astro/iraf/linux-64/anaconda2_4.2.0
     . /astro/iraf/linux-64/anaconda2_4.2.0/bin/activate

  At GS, this is done as rtfuser (and later copied to the file server as iraf).

* If appropriate, create a link to make the new installation your default:

  .. code-block:: sh

     cd /astro/iraf/linux-64
     ln -s anaconda2_4.2.0 anaconda

.. _conda_channels:

* If AstroConda has not been installed anywhere on this machine before (as the
  same user), configure the appropriate conda channels:

  .. code-block:: sh

     conda config --add channels http://ssb.stsci.edu/astroconda
     conda config --add channels http://astroconda.gemini.edu/public
     conda config --add channels file://rtfperm/ac_packages/gemini

  The second line may be unnecessary once STScI includes our IRAF packages in
  the main AstroConda channel, but is harmless if things are organized
  carefully. The last URL -- for internal packages -- is equivalent to 
  http://astroconda.gemini.edu/gemini (which is copied automatically from the
  same directory at GS every 15 minutes). The order in which the channels are
  defined determines their precedence, in reverse.

  .. _install_env:

* Create a new conda environment that includes the Gemini package versions you
  would like to install, plus the rest of AstroConda:

  .. code-block:: sh

     conda create -n dev_20161214 gemini-base gemini=dev_20161214

  The meta-package ``gemini-base`` pulls in specific versions of the packages
  from ``anaconda``, ``iraf-all``, ``pyraf`` and ``stsci``, giving a
  controlled, reproducible installation for testing and production use. This
  differs from ":ref:`laptop_install`", which uses the latest packages on the
  day of installation (depending also on the anaconda base version). These
  base packages can be updated by editing their version numbers in
  ``gemini-base/meta.yaml``, in this repository.

  Although ``gemini-base`` should theoretically allow running the same set of
  packages with different Anaconda base versions, it is best to use the version
  of Anaconda on which a given revision is based, so conda can link to its
  existing package set, rather than duplicating everything.

  Pending further testing, if you want to install Disco Stu, you need to add
  ``disco_stu`` to the above package list explicitly.

* If you would like to make your new environment the default for a given
  abbreviated name, create or modify the appropriate link:

  .. code-block:: sh

     cd /astro/iraf/linux-64
     rm dev
     ln -s anaconda2_4.2.0/envs/dev_20161214 dev

* Anaconda creates some files that are only readable by the user that installs
  it, causing major run-time breakage (which ranges from Qt and thus Matplotlib
  failing on Linux to the ``activate`` script itself failing on MacOS). You
  can just do the following to rectify this:

  .. code-block:: sh

     chmod -R a+r /astro/iraf/linux-64/anaconda2_4.2.0

  Whether this needs repeating whenever an environment is created with new
  Gemini package versions is TBC; I think it should be unnecessary.

* If you also need to make custom modifications, see :ref:`manual_packages`.


Synchronizing to the file server(s)
===================================

After installing or updating packages as described above, the files can be
copied from each primary build machine to the Netapp server (via any machine
that can write to its NFS automount path) as follows:

* SBF

  .. code-block:: sh

     rsync -navH --delete /astro/iraf/linux-64/ iraf@hostname:/net/sbfstonfs-nv1/tier1/sco/gss/iraf/linux-64/ > ~/rslog 2>&1

* HBF

  .. code-block:: sh

     rsync -navH --delete /astro/iraf/linux-64/ iraf@hostname:/net/hbf-nfs/sci/astro/iraf/linux-64/ > ~/rslog 2>&1  # (untested)

where `hostname` can be a maintainer's own desktop machine, such as `cactus` at
GS. After checking ``~/rslog`` to ensure that the correct files will be
updated, the same command is repeated without the ``-n`` flag (whose purpose is
just to show what rsync will do, without really copying or deleting any files).
The ``-H`` is needed to copy Anaconda's hard links without duplication. Note
that using ``-n`` with ``-H`` can produce errors like
``stat "some_file" failed: No such file or directory (2)``, but these go away 
when doing the real transfer.

The procedure for synchronizing files from the SBF server to the GS summit file
server is similar, but involves issuing formal change requests etc. (which are
beyond the scope of this document) and the relationship between these servers
needs revisiting anyway, after our recent move to base operations, so this will
not be covered here for the time being.


Usage
=====

The draft ``gempython.sh`` script in this repository can be sourced to
configure a user's shell environment to use the network AstroConda
installation. It behaves similarly to previous incarnations for Ureka / telops
and our historical `i686` (etc.) installations. The Anaconda version
(eg. `4.2.0`) and environment (eg. `dev` or `dev_20161214`) to use can be
overridden via ``ACVER`` and ``GEMVER`` environment variables, respectively,
otherwise the latter normally defaults to ``internal`` (in whichever
installation the link points to), but is set to ``dev`` during initial testing.

A csh-compatibility version of this script still needs writing; its usage
cannot be completely analagous (unless we support our own non-standard Anaconda
environment setup), as it will have to source ``activate`` in bash before
running the user's shell.

.. note::
   Until the current major re-write of Gemini Python is complete, ``dev`` is
   the only available version of Gemini Python or Gemaux for AstroConda (this
   probably isn't actually functional, but at least the imports should be
   working, for testing purposes).

