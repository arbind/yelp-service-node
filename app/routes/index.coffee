appData = null

exports.index = (req, res) -> res.render "index", title: "Food Truck Twitter Streams", data: req.biz || req.results

# load routes
exports.user            = (require './user')
# exports.oauth_twitter   = (require './oauth_twitter')
# exports.tweet_streamers = (require './tweet_streamers')
