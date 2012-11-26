appEnvironment = (require '../config/application')

socketIO      = (require 'socket.io')
express       = (require 'express')
http          = (require 'http')
path          = (require 'path')
connectAssets = (require 'connect-assets')

Yelp          = require('yelp')

routes        = (require './routes')
user          = (require './routes/user')

app = express()
app.use express.cookieParser()
app.use express.session secret: 'foodtrucko'
assetsPipeline = connectAssets src: 'app/assets'
css.root = 'stylesheets'
js.root = 'javascripts'

# Yelp = require('yelp')
# yelp = Yelp.createClient({consumer_key: 'EdtIXf4NMUBXh8XoysxW2Q',  consumer_secret: 'hMUNaKi1Oa_d7OvlHH0d2_7d7-M',  token: 'p4KFTaHrRR6oTGNOzGq28G9lrdgssyId',  token_secret: '8Zvy3k9wMPQflJs7Ztgq9w2uE1c'})
# yelp.business("yelp-san-francisco", function(error, data) { console.log(error || data) })

yelp = Yelp.createClient
  consumer_key: 'EdtIXf4NMUBXh8XoysxW2Q'
  consumer_secret: 'hMUNaKi1Oa_d7OvlHH0d2_7d7-M'
  token: 'p4KFTaHrRR6oTGNOzGq28G9lrdgssyId'
  token_secret: '8Zvy3k9wMPQflJs7Ztgq9w2uE1c'

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

# doesn't seem to work for yelpId: julios-café-austin-2
yelpBiz = (yelpid, searchResult, next)->
  console.log 'biz searchingggg'
  yelp.business yelpid, (error, data)->
    console.log data
    searchResult.error = error
    searchResult.biz = data
    next()

yelpSearch = (searchQuery, searchResult, next)->
  console.log 'searchQuery'
  console.log searchQuery
  term = searchQuery.term
  location = searchQuery.location
  lookupBiz = searchQuery.lookupBiz?  # boolean
  if location? and term?
    page = searchQuery.page || 1
    offset = (page-1)*20
    limit = if lookupBiz then 1 else 20
    q = 
      term: searchQuery.term
      location: searchQuery.location
      limit: limit
      offset: offset
    console.log q
    console.log q
    yelp.search q, (error, data)->
      console.log data
      searchResult.results = data
      next()
  else
    next()


renderIndex = (res, searchResult)-> res.render "index", title: 'search', error: searchResult.error, data: searchResult

###
#   REST Endpoints
#     eg: 
###
app.get '/biz/:yelpid', (req, res)-> res.render "index", title: "lookup", error: req.searchResult.error, data: req.searchResult.biz

app.param 'yelpid', (req, res, next, yelpid)->
  req.searchResult ||= {}
  yelpBiz yelpid, req.searchResult, next


###
#   Endpoints With Query Parameters
#     help to easily encode complex values like location
#     eg: 
###
app.get '/biz', (req, res)-> 
  searchResult = {}
  next = ()-> renderIndex(res, searchResult)

  yelpId = req.query.id || req.query.yelpid || req.query.yelpId || null
  if yelpId?
    (yelpBiz yelpId, searchResult, next)
  else
    searchQuery = 
      term: req.query.term || req.query.name || req.query.q || null
      location: req.query.location || req.query.l || null
      page: req.query.page || 1
    searchQuery.lookupBiz = if searchQuery.location? then true else false
    (yelpSearch searchQuery, searchResult, next)

app.get '/search', (req, res)->
  res.render "index", title: '', data: req.searchResult.results
  
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

  # socket.on 'search', (term, location) => # lookup tweets for streamer

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
