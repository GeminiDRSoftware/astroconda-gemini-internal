.. _manual_packages:

Patching in non-conda packages
******************************

These methods allow for making quick, centralized or per-user changes to an
installation. For routine maintenance, it is preferable to work with conda
packages, to avoid circumventing configuration control with conda's built-in
version and dependency tracking.


IRAF
====

extern.pkg

  In our re-worked AstroConda IRAF, ``extern.pkg`` is now user-editable, so you
  can modify a given environment's package & task definitions directly:

    .. code-block:: sh

       $EDITOR "$CONDA_PREFIX/extern.pkg"

  If you subsequently re-install Conda IRAF packages, any existing manual
  definitions will be preserved before their replacement entries (unless
  identical apart from the path), for reference.

login.cl

  Individual users can, of course, add or override packages in their own
  ``login.cl`` file.


Python
======

pip

  Conda is aware of packages added or removed using ``pip (un)install`` in the
  currently-active conda environment. Likewise, dependencies installed with
  conda are detected by ``pip`` in site-packages, as usual.

  Beyond the above, it is unclear to what extent the dependency tracking is
  interoperable (eg. whether pip can satisfy a conda dependency, as inadvisable
  as that probably is). There also seems to be an unwritten assumption of
  package naming consistency -- presumably because both Anaconda and PyPI use
  the names defined in setup.py by Python package authors, or because users are
  expected to use the conda versions where both exist -- though formally, the
  naming convention makes no such assurances:
  http://conda.pydata.org/docs/building/pkg-name-conv.html.

distutils / setuptools

  Since conda environments are typically user-writeable, one can do ``python
  setup.py install`` into an active environment (or simply modify source
  files) for testing, just as with ``virtualenv``, at the risk of creating an
  irreproducible configuration.

PYTHONPATH

  Anaconda neither relies on nor changes the behaviour of ``PYTHONPATH``, which
  can therefore be used to develop or test modules against an existing
  AstroConda environment, without altering it directly.

.. note::
   When using Anaconda, ``conda create`` should be used instead of
   ``virtualenv``, where needed.

