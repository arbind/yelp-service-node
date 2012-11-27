appEnvironment = (require '../config/application')

socketIO      = (require 'socket.io')
express       = (require 'express')
http          = (require 'http')
path          = (require 'path')
connectAssets = (require 'connect-assets')


routes        = (require './routes')
user          = (require './routes/user')

app = express()
app.use express.cookieParser()
app.use express.session secret: 'foodtrucko'
assetsPipeline = connectAssets src: 'app/assets'
css.root = 'stylesheets'
js.root = 'javascripts'

app.configure ->
  app.set 'port', process.env.PORT || process.env.VMC_APP_PORT || 8888
  app.set 'views', (__dirname + '/views')
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser('your secret here')
  # app.use express.session()
  app.use app.router
  app.use express.static(path.join(__dirname, 'public'))
  app.use assetsPipeline
  # app.use(require('stylus').middleware(__dirname + '/public'));

app.configure 'production', -> app.use express.errorHandler()
app.configure 'development', -> app.use (express.errorHandler dumpExceptions: true, showStack: true )

renderIndex = (res, searchResult)-> res.render "index", title: 'search', error: searchResult.error, data: searchResult

###
#   REST Endpoints
#     eg: 
###
app.get '/biz/:yelpid', (req, res)-> res.render "index", title: "lookup", error: req.searchResult.error, data: req.searchResult.biz

app.param 'yelpid', (req, res, next, yelpid)->
  req.searchResult ||= {}
  yelper.biz "session-id2", yelpid, (err, biz)->
    req.searchResult =  { biz: biz }
    next()

###
#   Endpoints With Query Parameters
#     help to easily encode complex values like location
#     eg: 
###
app.get '/biz', routes.yelp.biz
app.get '/name', routes.yelp.name
app.get '/search', routes.yelp.search

app.get ['/', '/index'], routes.index

# app.get '/users', routes.user.list
# TweetStreamService.on 'Tweet', (tweet)->
#   # console.log tweet.toJSON()
# TweetStreamService.on 'error', (err, streamer_screen_name, streamer_location)->
#   console.log "!! #{streamer_screen_name}[#{streamer_location}]: Unexpected Error!"
#   console.log err

httpServer  = http.createServer app
io          = socketIO.listen httpServer

httpServer.listen (app.get 'port'), -> 
  console.log "Express server listening on port #{app.get 'port'}"
# Heroku doesn't yet allow use of WebSockets: setup long polling instead.
# https://devcenter.heroku.com/articles/using-socket-io-with-node-js-on-heroku
# https://github.com/LearnBoost/Socket.IO/wiki/Configuring-Socket.IO
io.configure ->
  (io.set "transports", ["xhr-polling"])
  (io.set "polling duration", 10)
  (io.set "log level", 2) 

io.sockets.on 'connection', (socket)->
  console.log 'connected'

  # socket.on 'biz', (yelp_id_list) => # lookup tweets for user
  # socket.on 'search', (term, location, options) => # lookup tweets for streamer
  # options: page, sort, categoryFilter, deals   : http://www.yelp.com/developers/documentation/v2/search_api

  # TweetStreamService.on 'Tweet', (tweet)-> 
  #   tweet.emitTo(socket) # emit any new tweets that stream in

  # socket.on 'user-tweets', (screen_name) => # lookup tweets for user
  #   TweetStoreService.findUserTweets screen_name, (err, tweets) ->
  #     tweet.emitTo(socket) for tweet in tweets if tweets?

  # socket.on 'streamer-tweets', (screen_name) => # lookup tweets for streamer
  #   TweetStoreService.findStreamerTweets screen_name, (err, tweets) ->
  #     tweet.emitTo(socket) for tweet in tweets if tweets?

  # socket.on 'set nickname', (name)->
  #   socket.set 'nickname', name, () ->
  #     socket.emit 'ready'

  # socket.on 'msg', ->
  #   socket.get 'nickname', (err, name)->
  #     console.log "chat message from #{name}"
