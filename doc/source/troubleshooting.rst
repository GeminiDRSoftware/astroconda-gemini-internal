Troubleshooting
***************

* Occasionally, conda can install a corrupt version of a package, eg. with
  files missing, in which case you need to re-install it forcibly as follows,
  to clear the corrupted copy from the cache:

  .. code-block:: sh

     conda install -f package

  I think one example of this problem is
  ``FileNotFoundError: [Errno 2] No such file or directory:
  '/anaconda/envs/...'`` from ``conda create / install``, during
  "Linking packages ...". I suspect this may happen after the machine runs out
  of disk space on a previous installation attempt.

  There is also a ``conda clean`` command that can be used when explicitly
  removing and re-installing an environment or some of its packages.

* Users can break specific programs by installing a permitted but incompatible
  mixture of packages from Anaconda and Conda Forge.

  - Eg. someone reported that command recall with arrow keys was broken in
    PyRAF and Python, which I think happened because he had installed a
    conda-forge version of python that expects to find its ncurses dependency
    in a different place from the standard build.

See also http://conda.pydata.org/docs/troubleshooting.html.

