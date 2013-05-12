jade = require 'jade'
fs = require 'fs'

Q = require 'q'
_ = require 'lodash'

module.exports = class JadedBrunchPlugin
  brunchPlugin: yes
  type: 'javascript'
  extension: 'jade'
  jadeOptions: {}
  staticPath: 'public'

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

  templateFactory: (options, path) ->
    deferred = Q.defer()

    # TODO: Should I really assume utf-8?
    promise = fs.readFile path, 'utf-8', (error, data) ->
      if error
        deferred.reject new Error error
      else
        template = jade.compile data, options
        deferred.resolve template

    return deferred.promise

  compile: (data, path, callback) ->
    options = @makeOptions data

    errorHandler = (error) -> callback error
    successHandler = (template) ->
      output = template options

      if @staticPatterns?
        if not _.isArray @staticPatterns.test
          patterns = [@staticPatterns]
        else 
          patterns = @staticPatterns

        results = _.filter patterns, (pattern) -> pattern.test path

        if results.indexOf true != -1
          # TODO: Create static files. 
          return false

      callback null, output

    promise = @templateFactory options, path

    promise.done successHandler
    promise.fail errorHandler

