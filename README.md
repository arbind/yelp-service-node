## YelpAPI 2.0 Service
# Implements [Yelp for Developerers](http://www.yelp.com/developers/documentation/faq) Tech Requirements
Not yet stable!

### To Start Server:
````
npm install
npm start
````

### To Start Client:
````
browse to [ http://localhost:8888 ]
````

### To Execute Specs:
````
mocha -R spec --compilers cofee:coffee-script spec/*/*/*
````
### &#10003; The MVP #1 REST API (In Progress):
1. &#10003; find biz by yelpId
  * &#10003; /sessions/:sessionId/biz?yelpId=:yelpid
  * &#10003; returns 1 biz
2. &#10003; multi-find biz by yelpId
  * &#10003; /sessions/:sessionId/multi-biz?yelpIds=id-1, id-2, id-3, id-4, ...
  * &#10003; returns a list of biz that maps to the list of yelp-ids
3. &#10003; find biz by name
  * &#10003; /name?name=:name&location=:location
  * &#10003; returns 1 biz
4. &#10003; search for businesses:
  * &#10003; /search?term=:term&location=:location[&page=:page]
  * &#10003; returns 20 businesses per page
5. &#10003; Accept sessions tokens for each request (send the rails session id)
  * &#10003; cache biz lookups for each session
  * &#10003; caches biz for the session (conforms to yelp api developer's agreement)
  * &#10003; expire session after 30min

### &Xi; MVP #2 Socket API:
6. &Xi; biz-by-id (sessionId, yelpId)-> event
7. &Xi; multi-biz-by-ids (sessionId, yelpIdList) event
  * &Xi; streams each biz async 1 at a time back to calling client

### &Xi; MVP #3 integrate redis_message_capsule API:
8. &Xi; fire notification whenever a biz by id is looked up from cache
9. &Xi; fire notification whenever a biz by id is retrieved from yelp
10. &Xi; biz-by-id (yelpId)-> event
11. &Xi; multi-biz-by-ids (yelpIdList) event
12. &Xi; biz-by-name event (name, location)->
13. &Xi; search event (term, location [, page])


### &Xi; TO DO
````
+ deploy to heroku
+ write tests
+ setup cakefile
+ MVP #2
+ MVP #3
````

> **Key**

> &#10003; Complete

> &hearts; In Progres

> &Xi; ToDo
