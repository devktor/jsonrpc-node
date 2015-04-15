BasicAuth = require "./http_server_basic_auth"

Server = module.exports = (opt)->
  handler = (req, res, next)->
    handler.handle req, res, next
  handler.__proto__ = Server
  handler.methods = {}
  if opt? then handler.register opt
  handler

Server.register = (method, callback)->
  if !callback?
    if method instanceof Function
      @defaultMethod = method
    else
      for own key, callback of method
        @methods[key] = callback
  else
    @methods[key] = callback

Server.handle = (req, res, next)->
  if @auth? and !@auth req
    res.status(401).send({error:"Unauthorized"})
  else
    try
      request = if req.body instanceof Object then req.body else JSON.parse req.body
      response = @execute request.method, request.params
      response.id = if request.id? then request.id else null
      res.header "Content-Type", "application/json"
      code =  if response.error? then 400 else 200
      res.status(code).send(JSON.stringify response)
    catch e
      console.warn(e);
      res.status(500).send({error: "invalid request"})

Server.execute = (method, params)->
  if @methods[method]?
    result = @methods[method](params)
  else
    if @defaultMethod?
      result = @defaultMethod method, params
    else
      {error: "method #{method} not found"}
  if result instanceof Object then result else {result: result}


Server.setAuth = (@auth)->

Server.setBasicAuth = (authorize)->
  @setAuth new BasicAuth authorize


Server.listen = (port, host, callback)->
  @app = require('express')()
  @server = require('http').createServer app
  @app.use @
  @server.listen port, host, callback

Server.listenSSL = (port, host, key, cert, callback)->
  @app = require("express")()
  @server = require("https").createServer {key:key, cert:cert}, @app
  @server.listen port, host, callback
