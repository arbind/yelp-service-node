socket = io.connect()
socket.on 'connect', ->
  socket.on 'biz', (bizData)-> ($ 'body').trigger 'biz', bizData

window.loadUserTweets = (screen_name) -> socket.emit 'user-tweets', screen_name #'GGCvegas'
window.loadStreamerTweets = (screen_name) -> socket.emit 'streamer-tweets', screen_name # 'FTMUSTXAUS'

window.ClientApp = class ClientApp
  @views:{}
  @adapters: {}
  
# backbone
$ ->
  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };

  window.YelpBiz = Backbone.Model.extend()

  window.YelpBizList = Backbone.Collection.extend
    model: YelpBiz

  window.YelpBizDisplay = Backbone.View.extend
    el: "#yelp-template"

    initialize: () ->
      @template = _.template @$el.html();

    render: () ->
      @el = @template @model

  window.YelpBizListDisplay = Backbone.View.extend
    el: '#biz-list'
    initialize: () ->
      @collection = new YelpBizList
      ($ 'body').bind 'biz', (ev, bizData) => @collection.add new YelpBiz bizData
      @collection.on 'add', @addBiz, @
      @render

    addBiz: (biz) ->
      yelpBizDisplay = new YelpBizDisplay
        model: biz
      x = yelpBizDisplay.render()
      $x = ($ x)
      ($ '#biz-list').prepend $x
      $x.slideDown('slow')

    render: () ->

  window.YelpApp = class YelpApp
    constructor: () ->
      @yelpBizListDisplay = new YelpBizListDisplay
      bizList = if appData.bizList? then appData.bizList else if appData.biz? then [ appData.biz ] else if appData.searchResults? then appData.searchResults.businesses else []
      @yelpBizListDisplay.addBiz(biz) for biz in bizList

    render: () ->
      @yelpBizListDisplay.render()

  window.app = new YelpApp
  app.render()
