jaded-brunch [![CircleCI](https://circleci.com/gh/monokrome/jaded-brunch.svg?style=svg)](https://circleci.com/gh/monokrome/jaded-brunch)
============

Adds flexible jade support to [brunch](http://brunch.io).

Installation
------------

Install the plugin via npm with `npm install --save jaded-brunch`.

Or, do manual install:

* Add `"jaded-brunch": "x.y.z"` to `package.json` of your brunch app.
  Pick a plugin version that corresponds to your minor (y) brunch version.

* If you want to use git version of plugin, add
  `"jaded-brunch": "git+ssh://git@github.com:monokrome/jaded-brunch.git"`.

This will install jaded-brunch, and your project will automatically be
compiling all jade templates with the extension `.jade`. Files with the
extension `.static.jade` will automatically be compiled as static files
instead of being inserted as javascript templates.

You can configure the expression used to decide which files are static 
using the `plugins.jaded.staticPatterns` option as described in the next
section.

Usage
-----

For dynamic templates, jaded-brunch works just like any other brunch plugin. No
configuration is necessary. If you want to use the extension '.static.jade' for
your static files, the no configuration should be necessary for those either.

In order to provide support for more flexible ways of using static templates
jaded-brunch leverages a specific setting called `staticPatterns` which should
be a regular expression (or a list of regular expressions) with at least one
match. The last match in each expression will be suffixed with `.html` in order
to produce the actual filename of the static file which is created.

For instance, you could match all files with a `.jade` extension (instead of
the default `.static.jade`) - but only if they are in app/static. In order to
do this, you would use the following pattern:

    exports.config =
      plugins:
        jaded:
          staticPatterns: /^app(\/|\\)static(\/|\\)(.+)\.jade$/

Now, the file `app/static/about/contact_us.jade` will be statically compiled
as 'about/contact_us.html' in your public directory.

You can also pass arbitrary options to the jade compiler. This is done with
the `jade` option, so if you wanted your output to enable the pretty setting
you could use the following:

    exports.config =
      plugins:
        jaded:
          jade:
            pretty: yes

All options from [the jade API][api] can be provided this way.


[api]: http://jade-lang.com/api/ "Jade API"

