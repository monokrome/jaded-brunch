jade = require 'jade'
fs = require 'fs'
path = require 'path'

Q = require 'q'
_ = require 'lodash'

module.exports = class JadedBrunchPlugin
  brunchPlugin: yes
  type: 'template'
  extension: 'jade'
  jadeOptions: {}

  staticPath: 'public'
  projectPath: path.resolve process.cwd()

  constructor: (@config) ->
    @configure()

  configure: ->
    if @config.plugins?.jaded?
      options = @config.plugins.jaded

      if options.staticPatterns?
        @staticPatterns = @config.staticPatterns

      if options.jade?
        @jadeOptions = options.jade

      if options.path?
        @staticPath = options.path

  makeOptions: (data) ->
    # Allow for default data in the jade options hash
    if @jadeOptions.locals?
      locals = _.extend {}, @jadeOptions.locals, data
    else
      locals = data

    # Allow for custom options to be passed to jade
    options = _.extend {}, @jadeOptions,
      locals: data

  templateFactory: (options, templatePath) ->
    deferred = Q.defer()

    # TODO: Should I really assume utf-8?
    promise = fs.readFile templatePath, 'utf-8', (error, data) ->
      if error
        deferred.reject new Error error
      else
        template = jade.compile data, options
        deferred.resolve template

    return deferred.promise

  compile: (data, originalPath, callback) ->
    templatePath = path.resolve originalPath
    options = @makeOptions data

    errorHandler = (error) -> callback error
    successHandler = (template) ->
      output = template options

      if @staticPatterns?
        if not _.isArray @staticPatterns
          patterns = [@staticPatterns]
        else 
          patterns = @staticPatterns

        results = _.filter patterns, (pattern) -> pattern.test templatePath

        if results.indexOf true != -1
          # TODO: Create static files. 
          return false

      callback null, output

    promise = @templateFactory options, templatePath

    promise.done successHandler
    promise.fail errorHandler

