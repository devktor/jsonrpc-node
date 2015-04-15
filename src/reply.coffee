

Reply = module.exports = (session, id, method)->
  handler = (text)->
    handler.message text
  handler.__proto__ = Reply
  handler.session = session
  handler.id = id
  handler.method  = method
  handler


Reply.message = (args)->
  @session.sendReply @id, @method, args



Reply.error = (text)->
  @session.sendError @id, @method, text


Reply.notify = (args)->
  @session.sendNotification @method, args


module.exports = Reply