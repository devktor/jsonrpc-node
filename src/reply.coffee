

Reply = module.exports = (session, id, method)->
  handler = (text)->
    handler.message text
  handler.__proto__ = Reply
  handler.session = session
  handler.id = id
  handler.method  = method
  handler


Reply.message = (args)->
  @session.sendMessage @id, @method, args



Reply.error = (text)->
  @session.sendError @id, @method, text


Reply.notify = (text)->
  @session.sendNotification @method, text


module.exports = Reply