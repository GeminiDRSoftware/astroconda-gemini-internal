.. _building_packages:

Generating Conda packages
*************************

It is suggested that you use separate Anaconda installations for constructing
your /astro/iraf installation (on the primary build machines) and for building
packages. At GS, the latter installations are kept in /rtfproc on every build
machine::

  /rtfproc/anaconda2_4.2.0
           anaconda -> anaconda2_4.2.0

This separation avoids mixing an installation that needs to be stable and
well-controlled with one that undergoes more changes and is easily replaceable
from scratch if something goes wrong. Moreover, at GS there is insufficient
disk space in our /astro/iraf partitions to store a lot of intermediate build
products, so working in /rtfproc helps avoid builds running out of space.

.. note:: Build details to be added.

.. Path length.

