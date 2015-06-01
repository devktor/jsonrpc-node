

Reply = module.exports = (session, id)->
  handler = (text)->
    handler.message text
  handler.__proto__ = Reply
  handler.session = session
  handler.id = id
  handler


Reply.message = (args)-> @session.sendReply @id, args



Reply.error = (text)-> @session.sendError @id, text


Reply.notify = (method, args)-> @session.sendNotification method, args


module.exports = Reply