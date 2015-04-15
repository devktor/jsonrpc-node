BasicAuth = require "./http_server_basic_auth"
parser = require("body-parser")
Reply = require "./reply"

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
      res.header "Content-Type", "application/json"
      reply = new Reply res, request.id, request.method
      @execute request.method, request.params, reply
    catch e
      console.warn(e);
      res.status(500).send({error: "invalid request"})
    next?()

Server.execute = (method, params, reply)->
  if @methods[method]?
    @methods[method](params, reply)
  else
    if @defaultMethod?
      @defaultMethod method, params, reply
    else
      reply.error "method #{method} not found"

Server.setAuth = (@auth)->

Server.setBasicAuth = (authorize)->
  @setAuth new BasicAuth authorize


Server.listen = (port, host, callback)->
  @app = require('express')()
  @server = require('http').createServer @app
  @_listen port, host, callback

Server.listenSSL = (port, host, key, cert, callback)->
  @app = require("express")()
  @server = require("https").createServer {key:key, cert:cert}, @app
  @_listen port, host, callback

Server._listen = (port, host, callback)->
  @app.use(parser.json());
  @app.use @
  @server.listen port, host, callback
