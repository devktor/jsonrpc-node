

Reply = module.exports = (session, id, method)->
  handler = (text)->
    handler.message text
  handler.__proto__ = Reply
  handler.session = session
  handler.id = id
  handler.method  = method
  handler


Reply.message = ()->
  @session.send id:@id, method:@method, params:arguments



Reply.error = (text)->
  @session.send id:@id, method:@method, error:text


Reply.notify = ()->
  @session.send id:null, method:@method, params:arguments


module.exports = Reply