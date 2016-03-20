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
      if (doc != null) {
         console.dir(doc);
      } else {
         callback();
      }
   });
};



app.get('/', function (req, res) {
  var jsonDict = {apple:1, banana:2};
  res.json(jsonDict);
});

app.post('/', function (req, res) {
  res.send('Got a POST request');
});

app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
  console.log('test');
});


/* ROUTES */

// add_user - Add user if not exists
app.post('/add_user', function (req, res) {
	console.log("This is request", req.body);
	//1. query to insert the user
	var insertUser = function(db, callback) {
	   db.collection('users').insertOne(req.body, function(err, result) {
	    assert.equal(err, null);
	    console.log("Inserted a USER");
	    callback();
	  }); 
	};

	//2. call database with query
	console.log("***** Insert into MongoDB ******");
	insertUser(db, function() {
      	db.close();
  	});

  	res.send('Got a add_user POST request');
});


// create_tracker - Create a tracker

// get_trackers - Get trackers for a user

// edit_tracker - Edit a tracker
// delete_tracker - Delete a tracker
// count_up_tracker - Add a count for a tracker
// count_down_tracker - Remove a count for a tracker
