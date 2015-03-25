net = require "net"
Session = require "./session"
Reply = require "./reply"

Server = module.exports = (opt)->
  handler = (socket)->
    handler.handle socket
  handler.__proto__ = Server
  handler.methods = {}
  handler.counter = 0
  handler.socket = net.createServer handler
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
    @methods[method] = callback


Server.handle = (socket)->
  socket.setEncoding "utf-8"
  session = new Session socket
  session.id = ++@counter
  session.on "message", (msg)=>
    @execute session, msg
  session.on "error", (msg)-> console.log "session #{session.id} error: ",msg
  session.on "close", ()-> console.log "session #{session.id} closed"
  console.log "new connection #{session.id}"


Server.execute = (session, msg)->
  reply = new Reply session, msg.id, msg.method
  if @auth? and !session.authenticated? and !@auth msg, session
    reply.error "not authenticated"
  else
    method = @methods[msg.method]
    args = if msg.params? and Array.isArray msg.params then msg.params else []
    if method?
      method args, reply
    else
      if @defaultMethod?
        @defaultMethod msg.method, args, reply
      else
        reply.error "method not found"

Server.on = (event, callback)->
  @socket.on event, callback

Server.listen = ()->
  @socket.listen.apply @socket, arguments


Server.setAuth = (@auth)->

