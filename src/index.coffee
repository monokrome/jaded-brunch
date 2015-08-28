fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'

_ = require 'lodash'
progeny = require 'progeny'


# Allows modules included by jaded-brunch to be overwritten by
# a module in the current working directory's ./node_modules.
localRequire = (module) ->
  try
    modulePath = path.join process.cwd(), 'node_modules', module
    return require modulePath

  catch userError
    throw userError unless userError.code is 'MODULE_NOT_FOUND'

    try
      return require module

    catch localError
      throw localError


module.exports = class JadedBrunchPlugin
  brunchPlugin: yes
  type: 'template'
  extension: 'jade'
  jadeOptions: {}

  staticPath: 'public'
  projectPath: path.resolve process.cwd()

  staticPatterns: /^app(\/|\\)(.+)\.static\.jade$/

  extensions:
    static: 'html'
    client: 'js'

  constructor: (@config) ->
    @configure()

    @getDependencies = progeny
      rootPath: @config.paths.root

  configure: ->
    if @config.plugins?.jaded?
      options = @config?.plugins?.jaded or @config.plugins.jade
    else if @config.plugins?.jade?
      options = @config?.plugins?.jaded or @config.plugins.jade
    else
      options = {}

    if options.staticPatterns?
      @staticPatterns = options.staticPatterns

    if options.locals?
      @locals = options.locals
    else
      @locals = {}

    if options.path?
      @staticPath = options.path
    else if @config.paths?.public?
      @staticPath = @config.paths.public

    if options.jade?
      @jadeOptions = options.jade
    else
      @jadeOptions = _.omit options, 'staticPatterns', 'path', 'module', 'extension', 'clientExtension', 'patches'

    @jadeOptions.compileDebug ?= @config.optimize is false
    @jadeOptions.pretty ?= @config.optimize is false

    jadePath = path.dirname require.resolve 'jade'

    @include = [
      path.join jadePath, '..', 'runtime.js'
    ]

    jadeModule = options.module or 'jade'

    @jade = localRequire jadeModule

    if options.extensions?
      for key, value of options.extensions
        @extensions[key] = value

    patches = options.patches or []
    patches = [patches] if _.isString patches

    patches.map (patch) =>
      console.log patch
      patchModule = localRequire patch
      patchModule @jade

  makeOptions: (data) ->
    # Allow for default data in the jade options hash
    if @jadeOptions.locals?
      locals = _.extend {}, @jadeOptions.locals, data
    else
      locals = data

    # Allow for custom options to be passed to jade
    return _.extend {}, @jadeOptions,
      locals: data

  templateFactory: (data, options, templatePath, callback, clientMode) ->
    try
      if clientMode is true
        method = @jade.compileClient
      else
        method = @jade.compile

      template = method data, options

    catch e
      error = e

    callback error, template, clientMode

  compile: (data, originalPath, callback) ->
    templatePath = path.resolve originalPath

    if not _.isArray @staticPatterns
      patterns = [@staticPatterns]
    else
      patterns = @staticPatterns

    relativePath = path.relative @projectPath, templatePath
    pathTestResults = _.filter patterns, (pattern) -> pattern.test relativePath

    options = _.extend {}, @jadeOptions
    options.filename ?= relativePath

    successHandler = (error, template, clientMode) =>
      if error?
        callback error
        return

      if pathTestResults.length
        output = template @locals

        staticPath = path.join @projectPath, @staticPath
        matches = relativePath.match pathTestResults[0]

        if clientMode
          extension = @extensions.client
        else
          extension = @extensions.static

        outputPath = matches[matches.length-1]

        extensionStartIndex = (outputPath.length - extension.length)

        if outputPath[extensionStartIndex..] == extension
          outputPath = outputPath[0..extensionStartIndex-2]

        outputPath = outputPath + '.' + extension

        outputPath = path.join staticPath, outputPath
        outputDirectory = path.dirname outputPath

        # TODO: Save this block from an eternity in callback hell.
        mkdirp outputDirectory, (err) ->
          if err
            callback err, null
          else
            fs.writeFile outputPath, output, (err, written, buffer) ->
              if err
                callback err, null
              else
                callback(null, '')

      else
        callback null, "module.exports = #{template};"

    clientMode = pathTestResults.length == 0

    @templateFactory data, options, templatePath, successHandler, clientMode
