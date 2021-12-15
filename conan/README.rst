Conan CI
========

Goals
-----

- Make relocatable binary packages
- Speed up CI times by avoiding upstream SCINE dependency recompilations


Packaging philosophy
--------------------

Note that as a whole, the conan community has come to assume that any software
projects that is going to be packaged isn't going to get their CMake right.
'Right' in this case means that the package is relocatable (no hardcoded paths
in the CMake configuration files) and that all the required transitive
compilation flags for various platforms are correct. As a consequence, CMake
configuration files may not be part of binary packages, and Conan generates its
own CMake code for every project based on available information in the
conanfile. 


Setting boundaries
------------------

The way Conan generates CMake code as part of its generators naturally has its
own idiosyncracies which cannot possibly mirror the individual idiosyncracies of
every project's CMake code. However, we want the following properties regarding
our own Conan layer:

- All our projects build correctly without Conan and with their dependencies
  installed via package managers, manually, or downloaded in-tree.
- There should be no mention of Conan in our CMake files anywhere.
- Conan should be a thin layer around our CMake code that enables binary
  packaging and redistribution

As a consequence, we need to write some glue.


Glue
----

There is some 'adapting' CMake code in this repository that adapts what CMake
Conan generates to what each individual project usually exposes and we use in
our CMake code.

As an example, Conan will generate namespaced targets only, but many projects'
CMake generates non-namespaced targets. Conan will generate a ``cereal::cereal``
target, but cereal itself will only have a ``cereal`` target. The required
adapting CMake code is found in ``hook.cmake`` (which is dynamically injected
into our project's CMake code when conan builds them) and the ``glue``
subfolder.


File overview
-------------

- Common desired functionality of SCINE project conanfiles has been extracted to
  a common base class in ``base.py``.
  - Expose SCINE-wide CMake variable configuration
  - Define ABI compatibility (see ``SCINE_MARCH``)
  - Define minimum required properties for Conan CMake generator
- Small utility functions that the base conanfile uses are extracted into
  ``utils.py``
- ``hook.cmake`` is dynamically injected into every project's CMake code when
  built by Conan
- ``glue`` is the subfolder for more extensive adapting code for specific
  projects


Writing a new conanfile
-----------------------

If you want to add conan support to a new SCINE projects, it should be possible
to do so by imitation. Try these following:

- Copy some existing project's conanfile and adapt the data values therein.
- If you are missing dependencies, look for packages on conan-center-index.
- If the dependency hasn't been added by the conan community, have a look at the
  conan-recipes project on our gitlab for examples you can follow (this is
  possibly the trickiest bit).
- If your project has weird cross-dependencies or configuration idiosyncracies,
  have a look at all our projects' conanfiles. It's possible we've already had a
  problem like you have now and there's a simple solution that you can adopt.
- Look throuh conan's extensive documentation.
- Ask for help. People familiar with conan can probably get you on the
  right path quickly.


The artifactory
---------------

The artifactory is basically just a server where we store the binary packages
that conan generates. We've split it into two parts called repositories, a
private one (where all of our development packages go) and a public one (where
releases go).

You can access it `here <https://scine-artifactory.ethz.ch>`_. Your LDAP
credentials will work. You can add the repositories as conan remotes with::

    conan remote add -i 0 scine-private https://scine-artifactory.ethz.ch/artifactory/api/conan/private
    conan remote add -i 1 scine-public https://scine-artifactory.ethz.ch/artifactory/api/conan/public

Every conan CI job generates a package that is uploaded to the private
artifactory. Builds on ``develop`` git branches get no namespace at all, i.e.
they have the ``@_/_`` conan reference suffix. Builds on all other branches get
the suffix ``@scine/<shortened-branch-name>``.

The artifactory tracks when each package was last downloaded (by a user or by
another job that requires it as a dependency). Packages in the
private repository get deleted if the last time they were downloaded is more
than 14 days ago or so. Packages in the public repository don't get deleted.
Releases are immutable!
