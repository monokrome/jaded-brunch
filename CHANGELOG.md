# jaded-brunch 1.7.6

- Fixed a bug regarding how @jadeOptions worked. Now they actually do work.
- Leverage data passed in from brunch instead of reading data separately.

# jaded-brunch 1.7.5

- Fixed an issue causing jade errors to crash brunch.
- The expected interface for settings is now simply in the 'jade' plugin
  options. Any options that aren't specific to jaded-brunch are now forwarded
  to jade.
  - The previous structure will work until the next major release. (v1.8.0)
  - The old 'jaded' options - as well as the 'jade' suboption - is now
    deprecated in favor of the new approach.
- When optimize is not false during compilation, jaded-brunch will not
  compile jade templates containing debug content any more by default.
- Templates will now be compiled as 'pretty' when optimize is false by default.
- Added a Makefile.

# jaded-brunch 1.7.4

- Fixed issue with latest brunch not considering undefined as static to
  the callback function in compile.

# jaded-brunch 1.7.3

- Removed unnecessary extension option.

# jaded-brunch 1.7.2

- Modified getDependencies to use progeny
  - https://github.com/es128/progeny/

# jaded-brunch 1.7.1

- Updated jade to 0.33.0
- Fixued issue where jade errors terminated brunch.
  - Brunch should watch for plugin errors like this.

# jaded-brunch 1.7.0

- Added support for returning null from compiler.

# jaded-brunch 1.6.6

- Fixed issue caused by having more than one dependency in a file.

# jaded-brunch 1.6.5

- Upgraded jade requirements to use latest version.

# jaded-brunch 1.6.4

- Added support for resolving dependencies for watcher for the following
  jade language features:
  - extends
  - includes

# jaded-brunch 1.6.3

- Provided filename option to jade for static files.

# jaded-brunch 1.6.2

- Finished client-side jade rendering support.
- Modified static paths pattern to not include .static in output filenames.

# jaded-brunch 1.6.1

- Added default support to automatically use the default public path setting.

# jaded-brunch 1.6.0

- Initial working support of static jade rendering.
- Created plugin.
