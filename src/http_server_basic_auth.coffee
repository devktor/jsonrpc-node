module.exports = (authorize)->
  (req, callback)->
    if !req.headers.authorization? then return false
    token = req.headers.authorization
    parts = token.split(' ')
    if 'basic' != parts[0].toLowerCase() or !parts[1] then return false
    auth = new Buffer(parts[1], 'base64').toString();
    user = auth.split(':')
    if user.length != 2 then return false

    authorize user[0], user[1], callback