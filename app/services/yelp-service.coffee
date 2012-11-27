YelpLib = require('yelp')

class YelpService
  # class attributes
  @resultsPerPage: 20
  @sessionTTL: 60*60 # 1hr = 60s * 60m
  @bizTTL: 5*60*60   # 5hrs : worst case expiration for a yelp biz, so it doesn't get stale
  @client: (oauthConfig, redisClient)-> new YelpService oauthConfig, redisClient
  @clientAPI: null

  constructor: (@oauthConfig, @redisClient)->
    YelpService.clientAPI ||= YelpLib.createClient @oauthConfig

  # Finding a biz by its yelp-id will cache the biz for the session
  # doesn't seem to work for yelpId: julios-café-austin-2

  # 4 paths:
  # 1 biz is not in cache (1st ever search for biz)
  # 2 biz is in cache, and in session (user already searched for biz durring the session)
  # 3 biz is in cache, but not in session (user searched for biz before, but the session expired)
  # 4 biz is in cache, but not in session (1st search for biz by this user, but biz was alreay put in cache from another user)
  biz: (sessionId, yelpId, callback)=>
    # +++ TODO lookup from cache, queue up query to yelpAPI, if session has expired
    @redisClient.get yelpId, (err, bizJSON)=>
      if err?
        console.log "redis err"
        console.log err
        callback(err)
        return
      if bizJSON?
        console.log "rematerializing #{yelpId} from cache"
        console.log "returning #{yelpId} from cache"
        adaptedBiz = (JSON.parse bizJSON) if bizJSON?
        callback(err, adaptedBiz ) # immediately return the biz

        # see if yelp id is in session, if not, make a request
        @redisClient.hexists sessionId, yelpId, (err, alreadyExists)=>
          if 0 is alreadyExists
            console.log "#{yelpId} was not found in session"
            @redisClient.hmset sessionId, yelpId, ".", (err, ok)=># add the yelpId to this session
              console.log "#{yelpId} added to session"
              @redisClient.expire sessionId, YelpService.sessionTTL
            console.log "fetching #{yelpId} ..."
            YelpService.clientAPI.business yelpId, (err, yelpBiz)=>
              return if err?
              console.log "fetched #{yelpId} ..."
              adaptedBiz = (@_adaptBiz yelpBiz)
              bizJSON = (JSON.stringify adaptedBiz)
              @redisClient.set yelpId, bizJSON
              console.log "cache updated #{yelpId} ..."
              @redisClient.expire yelpId, YelpService.bizTTL
              console.log "refreshed expiration: #{yelpId}"
          else
            @redisClient.expire sessionId, YelpService.sessionTTL
            console.log "refreshed session"
      else 
        console.log "#{yelpId} not found in cache"
        console.log "fetching #{yelpId} ..."
        YelpService.clientAPI.business yelpId, (err, yelpBiz)=>
          if err?
            console.log "err fetching #{yelpId}"
            console.log err
            callback(err)
            return
          console.log "fetched #{yelpId} ..."
          console.log "returning #{yelpId} from fetch"
          adaptedBiz = (@_adaptBiz yelpBiz)
          callback(err, adaptedBiz)
          bizJSON = (JSON.stringify adaptedBiz)
          @redisClient.set yelpId, bizJSON
          console.log "cached #{yelpId} ..."
          @redisClient.expire yelpId, YelpService.bizTTL
          console.log "expiration set for #{yelpId}"

          @redisClient.hmset sessionId, yelpId, ".", (err, ok)=># add the yelpId to this session
            console.log "#{yelpId} added to session"
            @redisClient.expire sessionId, YelpService.sessionTTL
            console.log "expiration set for session"

  bizById:  (sessionId, yelpId, callback)=> (@biz sessionId, yelpId, callback)
  findById: (sessionId, yelpId, callback)=> (@biz sessionId, yelpId, callback)

  # The following search methods are not getting cached
  bizByName: (name, location, callback) =>
    searchQuery = 
      term:     name
      location: location
      offset:   0
      limit:    1
    @_search(searchQuery, callback)
  findByName: (name, location, callback)=> (@bizByName name, location, callback)

  search: (term, location, page, callback)=>
    unless callback? # set default page to 1
      callback = page
      page = 1
    @yelpSearchPage term, location, page, callback

  yelpSearchPage: (term, location, page, callback)=>
    searchQuery =
      term:     term
      location: location
      offset:   (page-1)* YelpService.resultsPerPage
      limit:    YelpService.resultsPerPage
    @_search(searchQuery, callback)

  _search: (searchQuery, callback)=>
    YelpService.clientAPI.search searchQuery, (err, searchResults)=>
      callback(err, (@_adaptSearchResults searchResults) )

  _adaptBiz: (biz)=>
    biz

  _adaptSearchResults: (searchResults)=>
    searchResults

module.exports = YelpService

# redis = require('redis-url').connect('redis://127.0.0.1:6379')
# redis.select 1

# Yelp = require('yelp')
# yelp = Yelp.createClient({consumer_key: 'EdtIXf4NMUBXh8XoysxW2Q',  consumer_secret: 'hMUNaKi1Oa_d7OvlHH0d2_7d7-M',  token: 'p4KFTaHrRR6oTGNOzGq28G9lrdgssyId',  token_secret: '8Zvy3k9wMPQflJs7Ztgq9w2uE1c'})
# yelp.business("yelp-san-francisco", function(err, data) { console.log(err || data) })

