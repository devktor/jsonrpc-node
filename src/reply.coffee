

Reply = module.exports = (session, id)->
  handler = (text)->
    handler.message text
  handler.__proto__ = Reply
  handler.session = session
  handler.id = id
  handler


Reply.message = (text)->
  @session.sendMessage @id, text



Reply.error = (text)->
  @session.sendError @id, text


module.exports = Reply