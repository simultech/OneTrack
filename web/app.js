var express = require('express');
/* bodyParser - enables getting POST params that user sends */
var bodyParser = require("body-parser");
var app = express();
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
/* mongodb setup */
var MongoClient = require('mongodb').MongoClient;
var assert = require('assert');
var ObjectId = require('mongodb').ObjectID;
var url = 'mongodb://localhost:27017/onetrackdb';
var db;
var shortid = require('shortid'); //generate unique id's for trackers
console.log(shortid.generate());


/* setting up one instance of MongoClient */
MongoClient.connect(url, function(err, database) {
	assert.equal(null, err);
	console.log("***** Setting MongoDB ******");
	db = database;
});


//example for querying
var findRestaurants = function(db, callback) {
   var cursor =db.collection('restaurants').find( );
   cursor.each(function(err, doc) {
      assert.equal(err, null);
      if (doc !== null) {
         console.dir(doc);
      } else {
         callback();
      }
   });
};



app.get('/', function (req, res) {
  var jsonDict = {apple:12, banana:10};
  res.json(jsonDict);
});

app.post('/', function (req, res) {
  res.send('Got a POST request');
});

app.listen(3000, function () {
  console.log('Exjj ample app listening on port 3000!');
  console.log('test');
});


/* ROUTES */

/* add_user - Add user if not exists */
app.post('/add_user', function (req, res) {
	console.log("This is add_user request", req.body);
	//1. query to insert the user
  var user = req.body;
  user.tracks = [];
	var insertUser = function(db, callback, error) {
	   db.collection('users').updateOne(
      {fb_id:req.body.fb_id},   //check if fb_id exists
      user,                 //if not insert req.body
      {upsert:true,safe:false}, //activate upsert
      function(err, result) {
      if(err !== null) {
        error(err);
      } else {
        console.log("Inserted a USER");
        callback();
      }
	  }); 
	};

	//2. call database with query
	console.log("***** Insert into MongoDB ******");
	insertUser(db, function() {
        res.send({'success':'true'});
  	}, function(message) {
        res.send({'success':'false', 'message':message});
    });

});

/* create_tracker - Create a tracker */
app.post('/create_tracker', function (req, res) {
  console.log("This is create_tracker request", req.body);
  //1. query to insert the user
  var trackerDict = req.body;
  trackerDict.id = shortid.generate();
  var insertTracker = function(db, callback, error) {
     db.collection('users').update(
      {fb_id:req.body.fb_id},//get object with fb_id
       {$push:{tracks:trackerDict}}, //push to tracks
       function(err, result) {
      if(err !== null) {
        error(err);
      } else {
        console.log("Insertedk a Tracker Z");
        callback(trackerDict.id);
      }
    }); 
  };

  //2. call database with query
  console.log("***** Insert into MongoDB ******");
  insertTracker(db, function(id) {
        res.send({'success':'true', 'id':id});
    }, function(message) {
        res.send({'success':'false', 'message':message});
    });
 //db.students.update(
//    { _id: 1 },
//    { $push: { scores: 89 } }
// )
});


// get_trackers - Get trackers for a user

// edit_tracker - Edit a tracker
// delete_tracker - Delete a tracker
// count_up_tracker - Add a count for a tracker
// count_down_tracker - Remove a count for a tracker
