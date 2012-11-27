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
### &hearts; The MVP #1 REST API (In Progress):
1. &hearts; find biz by yelpId
  * &hearts; /biz?yelpid=:yelpid&sessionid=:sessionid
  * &hearts; /biz/:yelpid/:sessionid (endpoint alias)
  * &#10003; caches the biz for the session (conforms to yelp api developer's agreement)
  * &#10003; returns 1 biz
2. &hearts; multi-find biz by yelpId
  * &hearts; /multi-biz?yelpids=:[id-1, id-2, id-3, id-4, ...] 
  * &hearts; returns a list of biz that maps to the list of yelp-ids
3. &#10003; find biz by name
  * &#10003; /name?name=:name&location=:location
  * &#10003; allows easy url encoding for name and location
  * &#10003; returns 1 biz
4. &hearts; search for businesses:
  * &hearts; /search?term=:term&location=:location[&page=:page]
  * &hearts; allows easy url encoding for name and location
  * &hearts; returns 20 businesses per page

### &Xi; MVP #2 integrate redis_message_capsule:
5. &Xi; fire notification whenever a biz by id is looked up from cache
6. &Xi; fire notification whenever a biz by id is retrieved from yelp

### &Xi; MVP #3 Socket API:
7. &Xi; biz-by-id (id)-> event
8. &Xi; multi-biz-by-ids (list) event
9. &Xi; biz-by-name event (name, location)->
10. &Xi; search event (term, location [, page])


### &Xi; TO DO
````
+ push this codebase to heroku
+ write tests
+ integrate redis_message_capsule
+ setup cakefile
+ MVP #1
+ MVP #2
+ MVP #3
````

> **Key**

> &#10003; Complete

> &hearts; In Progres

> &Xi; ToDo
