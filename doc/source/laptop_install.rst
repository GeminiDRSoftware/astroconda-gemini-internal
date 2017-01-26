.. _laptop_install:

Personal/laptop installation
****************************

Public distribution
===================

* Install the latest 64-bit, Python 2.7 version of Anaconda (or Miniconda) from
  https://www.continuum.io/downloads.

  .. note::

    The shell installer puts the distribution in "anaconda2/" by default,
    whereas the MacOS GUI puts it in "anaconda/".

* Make sure the default environment is activated in your bash/zsh session
  (Anaconda does not support csh directly):

  .. code-block:: sh

     source ~/anaconda/bin/activate  # (or wherever you put it)

* Add the main AstroConda "channel" (repo) and our testing channel:

  .. code-block:: sh

     conda config --add channels http://ssb.stsci.edu/astroconda
     conda config --add channels http://astroconda.gemini.edu/public

  This only needs doing once for a given user and affects all installations.
  The second channel will not usually be necessary once STScI publishes our
  changes.

* Install our packages (alongside Anaconda's) into a new conda environment,
  eg. *gemini*: 

  .. code-block:: sh

     conda create -n gemini python=2.7 anaconda iraf-all pyraf stsci

  (Do not install the packages into the root environment!)

* Activate the new environment:

  .. code-block:: sh

     source activate gemini

  (if adding this permanently to .bashrc, place it at the end and use the full
  path, eg. ``source "$HOME/anaconda/bin/activate" gemini``).


..  _internal_pkg_inst:

Installation with internal packages
===================================

Any Conda packages for internal versions of Gemini IRAF etc. are kept in an
internal channel, which should be defined after the others (so it will take
precedence):

  .. code-block:: sh

     conda config --add channels http://astroconda:password@astroconda.gemini.edu/gemini

  .. note::

     Substitute the staff astroconda password, from James.

Due to some bug in Anaconda 4.2.0 [#f1]_, you must currently update your conda
package to >=4.3.4 before the above authenticated URL will work:

  .. code-block:: sh

     conda update conda

A ``gemini`` meta-package can be used to install the full set of Gemini IRAF &
Python packages [#f_dev_only]_, specifying which tag version to use (where
available), which overrides any default versions in the public channels, eg.:

  .. code-block:: sh

     conda create -n dev anaconda iraf-all pyraf stsci gemini=dev

You may also specify Gemini packages individually, including mixed and dated
version tags, where needed for testing, commissioning etc.:

  .. code-block:: sh

     conda create -n new_ccds anaconda iraf-all pyraf stsci iraf.gemini=gsops_20161205 gemini.gemini_python=dev_20170101  # (untested example)

  .. note::

     Gemini Python is still being re-written to work with the recent dependency
     versions in AstroConda, amongst other purposes. For the time being, the 
     pipeline does not work properly in AstroConda (nor any similarly-recent
     Python installations).

See also :ref:`manual_packages`.

.. [#f1] https://github.com/conda/conda/issues/323#issuecomment-273243809

.. [#f_dev_only] Currently just for ``dev`` (which uses the ``QAP-2016-2_ac``
                 branch), until we have a proper AstroConda-compatible
                 version of Gemini Python.

