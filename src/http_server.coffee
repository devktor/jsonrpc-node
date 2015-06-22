BasicAuth = require "./http_server_basic_auth"
parser = require("body-parser")
Reply = require "./reply"

class Session
  constructor:(@res)->
  sendData:(obj)-> @res.json obj

  sendError:(id, message)->
    @res.status(500).json id:id, error:message||""

  sendNotification:(method, params)->
    @res.json id:null, method:method, result:if params? then params else ""

  sendReply:(id, params)->
    @res.json id:id, result:if params? then params else ""



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

Server.handle = (req, res)->
  if @auth?
    @auth req, (err, user)=>
      if err? or !user?
        console.log "#{req.connection.remoteAddress} not authorized : #{err}"
        res.status(401).json({error:"Unauthorized"})
      else
        @handleNoAuth req, res, user
  else
    @handleNoAuth req, res, undefined

Server.handleNoAuth = (req, res, user)->
  try
    request = if req.body instanceof Object then req.body else JSON.parse req.body
    reply = new Reply new Session(res), request.id
    @execute request.method, request.params, reply, user
  catch e
    console.warn "#{req.connection.remoteAddress} invalid request #{e}"
    res.status(500).json({error: "invalid request"})


Server.execute = (method, params, reply, user)->
  if @methods[method]?
    @methods[method](params, reply, user)
  else
    if @defaultMethod?
      @defaultMethod method, params, reply, user
    else
      console.warn "#{req.connection.remoteAddress} invalid requested method #{method}"
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
