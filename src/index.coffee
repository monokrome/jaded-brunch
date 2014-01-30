jade = require 'jade'
fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
progeny = require 'progeny'

_ = require 'lodash'

jadePath = path.dirname require.resolve 'jade'

module.exports = class JadedBrunchPlugin
  brunchPlugin: yes
  type: 'template'
  extension: 'jade'
  jadeOptions: {}

  outputExtension: 'html'
  staticPath: 'public'
  projectPath: path.resolve process.cwd()

  staticPatterns: /^app(\/|\\)(.+)\.static\.jade$/

  include: [
    path.join jadePath, 'runtime.js'
  ]

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

    if options.filterPhp? and options.filterPhp
      jadephp = require 'jade-php'
      jadephp jade

    if options.outputExtension?
      @outputExtension = options.outputExtension

    if options.staticPatterns?
      @staticPatterns = options.staticPatterns

    if options.path?
      @staticPath = options.path
    else if @config.paths?.public?
      @staticPath = @config.paths.public

    if options.jade?
      @jadeOptions = options.jade
    else
      @jadeOptions = _.omit options, 'staticPatterns', 'path', 'filterPhp', 'outputExtension'

    @jadeOptions.compileDebug ?= @config.optimize is false
    @jadeOptions.pretty ?= @config.optimize is false

  makeOptions: (data) ->
    # Allow for default data in the jade options hash
    if @jadeOptions.locals?
      locals = _.extend {}, @jadeOptions.locals, data
    else
      locals = data

    # Allow for custom options to be passed to jade
    options = _.extend {}, @jadeOptions,
      locals: data

  templateFactory: (data, options, templatePath, callback, clientMode) ->
    try
      if clientMode is true
        method = jade.compileClient
      else
        method = jade.compile

      template = method data, options

    catch e
      error = e

    callback error, template

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

    successHandler = (error, template) =>
      if error?
        callback error
        return

      if pathTestResults.length
        output = template()

        staticPath = path.join @projectPath, @staticPath
        matches = relativePath.match pathTestResults[0]

        outputPath = matches[matches.length-1]

        extensionStartIndex = (outputPath.length - @extension.length)

        if outputPath[extensionStartIndex..] == @extension
          outputPath = outputPath[0..extensionStartIndex-2]

        outputPath = "#{outputPath}.#{@outputExtension}"

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
                callback()

      else
        callback null, "module.exports = #{template};"

    clientMode = pathTestResults.length == 0

    @templateFactory data, options, templatePath, successHandler, clientMode
