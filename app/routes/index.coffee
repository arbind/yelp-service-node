# load routes
userRoutes = (require './user')
yelpRoutes = (require './yelp')

# set appData javascript variable for all responses (using express-expose)
app.all '*', (req, res, next) -> 
  res.expose({}, 'appData'); next()
  # res.expose ()->
  #   notify = ()-> alert('this will execute right away :D')
  #   notify()

# pre-processor: capture route params and move into req.query
app.param 'sessionId', (req, res, next, sessionId) -> req.query.sessionId = sessionId; next()

indexRoutes= [
  '/',
  '/index'
  ]
bizByIdRoutes= [
  '/sessions/:sessionId/biz',
  ]
multiBizByIdsRoutes = [
  '/sessions/:sessionId/multi-biz'
  ]
bizByNameRoutes= [
  '/name'
  ]
bizSearchRoutes= [
  '/search'
  ]

# Define the Application's Routes

#homepage
app.get indexRoutes,          indexRoutes.index

# Yelp Services
app.get bizByIdRoutes,        yelpRoutes.biz
app.get multiBizByIdsRoutes,  yelpRoutes.multiBiz
app.get bizByNameRoutes,      yelpRoutes.name
app.get bizSearchRoutes,      yelpRoutes.search

exports.indexRoutes = indexRoutes
exports.yelpRoutes = yelpRoutes

# exports.oauth_twitter   = (require './oauth_twitter')
# exports.tweet_streamers = (require './tweet_streamers')
