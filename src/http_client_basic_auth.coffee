class BasicAuthentication
  constructor:(@username, @password)->
  sign:(options, request)->
    options.auth = "#{@username}:#{@password}"

module.exports = BasicAuthentication