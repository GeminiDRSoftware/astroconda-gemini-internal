Troubleshooting
***************

* Occasionally, conda can install a corrupt version of a package, eg. with
  files missing, in which case you need to re-install it forcibly as follows,
  to clear the corrupted copy from the cache:

  .. code-block:: sh

     conda install -f package

* Users can break specific programs by installing a permitted but incompatible
  mixture of packages from Anaconda and Conda Forge.

  - Eg. someone reported that command recall with arrow keys was broken in
    PyRAF and Python, which I think happened because he had installed a
    conda-forge version of python that expects to find its ncurses dependency
    in a different place from the standard build.

See also http://conda.pydata.org/docs/troubleshooting.html.

