yelpOauthConfig =
  consumer_key: 'EdtIXf4NMUBXh8XoysxW2Q'
  consumer_secret: 'hMUNaKi1Oa_d7OvlHH0d2_7d7-M'
  token: 'p4KFTaHrRR6oTGNOzGq28G9lrdgssyId'
  token_secret: '8Zvy3k9wMPQflJs7Ztgq9w2uE1c'

yelper = YelpService.client(yelpOauthConfig, redis)

exports.biz = (req, res) ->
  console.log "biz"
  ( return exports.name(req, res) ) if req.query.name? and req.query.location?

  yelpId = req.query.id || req.query.yelpid || req.query.yelpId || null
  if yelpId?
    yelper.bizById "session-id2", yelpId, (err, biz)->
      data = {q:'biz', biz: biz}
      res.render "index", title: 'biz', error: err, data: data
  else
    res.send "No yelp ID"

exports.name = (req, res) ->
  console.log "name"
  if req.query.name? and req.query.location?
    yelper.bizByName req.query.name, req.query.location, (err, searchResults)-> 
      data = {q:'name', searchResults: searchResults}
      res.render "index", title: 'name', error: err, data: data
  else
    res.send "respond with a resource: yelp:name & location"

exports.search = (req, res) ->
  console.log "search"
  ( return exports.name(req, res) ) if req.query.name? and req.query.location?

  if req.query.term? and req.query.location?
    yelper.search req.query.term, req.query.location, req.query.page, (err, searchResults)-> 
      data = {q:'search', searchResults: searchResults}
      res.render "index", title: 'search', error: err, data: data
  else
    res.send "respond with a resource: yelp:term & location"

  # if req.query.term? and req.query.location?
  #   searchQuery = 
  #     term: req.query.term
  #     location: req.query.location
  #     page: req.query.page || 1
  #     # sort: req.query.sort || 1 +++ TODO add sort parameter throughout
  #   yelper.search  searchQuery, (err, searchResults)-> next results: searchResults
  # else
  #   res.render "index", title: '', data: {}
