net = require "net"
Session = require "./session"
Reply = require "./reply"

Server = module.exports = (opt)->
  handler = (socket)->
    handler.handle socket
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


Server.handle = (socket)->
  socket.setEncoding "utf-8"
  session = new Session socket
  session.on "message", (msg)=>
    @execute session, msg
  session.on "error", (msg)->


Server.execute = (session, msg)->
  if @auth? and !session.authenticated? and !@auth msg, session
    session.error msg.id, "not authenticated"
  else
    method = @methods[msg.method]
    args = if msg.params? and Array.isArray msg.params then msg.params else []
    args.unshift new Reply session, msg.id
    if method?
      method.apply method, args
    else
      if @defaultMethod?
        args.unshift msg.method
        @defaultMethod.apply @defaultMethod, args
      else
        session.error msg.id, "method not found"


Server.listen = ()->
  @socket = net.createServer @
  @socket.listen.apply @socket, arguments

Server.setAuth = (@auth)->

