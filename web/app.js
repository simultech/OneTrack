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
  var jsonDict = {apple:15, banana:10};
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
  user.fb_id = "_"+req.body.fb_id;
  user.tracks = [];
	var insertUser = function(db, callback, error) {
	   db.collection('users').updateOne(
      {fb_id:user.fb_id},   //check if fb_id exists
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
  var trackerDict = {};
  trackerDict.id = shortid.generate();
  trackerDict.name = req.body.name;
  trackerDict.maxCount = req.body.maxCount;
  trackerDict.deleted = false;
  trackerDict.count = [];
  var insertTracker = function(db, callback, error) {
    console.log("trackerDict", trackerDict);
    db.collection('users').updateOne(
      {"fb_id":"_"+req.body.fb_id},//get object with fb_id
      {$push:{"tracks":trackerDict}}, //push to tracks
      function(err, result) {
        if(err !== null) {
          error(err);
        } else {
          console.log("Inserted a Tracker", trackerDict);
          callback(trackerDict.id);
        }
      }
    );
  }; 
  //2. call database with query
  console.log("***** Insert into MongoDB ******");
  insertTracker(db, function(id) {
        res.send({'success':'true', 'id':id});
    }, function(message) {
        res.send({'success':'false', 'message':message});
    });
 });

// get_trackers - Get trackers for a user
app.get('/get_trackers', function (req, res) {
  console.log("This is get_trackers request", req.query);
  
  var getTrackers = function(db, callback, error) {
    var cursor =db.collection('users').find( { "fb_id": "_"+req.query.fb_id } );
    cursor.nextObject(function(err, doc) {
      assert.equal(err, null);
      if (doc !== null) {
        // console.dir('tracks', doc);
        callback(doc.tracks);
      } else {
         error(err);
      }
    });

  };


  console.log("***** Get Tracker  MongoDB ******");
  getTrackers(db, function(trackers) {
        res.json({'success':'true', 'trackers':trackers});
    }, function(message) {
        res.send({'success':'false', 'message':message});
    });
});


// edit_tracker - Edit a tracker
app.post('/edit_tracker', function (req, res) {
  console.log("This is edit_tracker request", req.body);
  //1. query to insert the user
  
  var editTracker = function(db, callback, error) {
    db.collection('users').updateOne(
      {"fb_id":"_"+req.body.fb_id, "tracks.id":req.body.track_id},//get object with fb_id
      {$set:{"tracks.$.name":req.body.name, "tracks.$.maxCount":req.body.maxCount}}, //push to tracks
      function(err, result) {
        if(err !== null) {
          error(err);
        } else {
          console.log("Edited a Tracker");
          callback();
        }
      }
    );
  };

  console.log("***** Edit Tracker into MongoDB ******");
  editTracker(db, function(id) {
        res.send({'success':'true'});
    }, function(message) {
        res.send({'success':'false', 'message':message});
    });

});

// delete_tracker - Delete a tracker
app.post('/delete_tracker', function (req, res) {
  console.log("This is delete_tracker request", req.body);
  //1. query to insert the user
  
  var deleteTracker = function(db, callback, error) {
    db.collection('users').updateOne(
      {"fb_id":"_"+req.body.fb_id, "tracks.id":req.body.track_id},//get object with fb_id
      {$set:{"tracks.$.deleted":true}}, //push to tracks
      function(err, result) {
        if(err !== null) {
          error(err);
        } else {
          console.log("Deleted a Tracker");
          callback();
        }
      }
    );
  };

  console.log("***** Delete Tracker into MongoDB ******");
  deleteTracker(db, function(id) {
        res.send({'success':'true'});
    }, function(message) {
        res.send({'success':'false', 'message':message});
    });

});

// count_up_tracker - Add a count for a tracker
app.post('/count_up_tracker', function (req, res) {
  console.log("This is count_up_tracker request", req.body);
  //1. query to insert the user
  
  var countUpTracker = function(db, callback, error) {
    db.collection('users').updateOne(
      {"fb_id":"_"+req.body.fb_id, "tracks.id":req.body.track_id},//get object with fb_id
      {$push:{"tracks.$.count":req.body.clickValue}}, //push to tracks
      function(err, result) {
        if(err !== null) {
          error(err);
        } else {
          console.log("Count UP Tracker");
          callback();
        }
      }
    );
  };

  console.log("***** Count UP Tracker into MongoDB ******");
  countUpTracker(db, function(id) {
        res.send({'success':'true'});
    }, function(message) {
        res.send({'success':'false', 'message':message});
    });
});
// count_down_tracker - Remove a count for a tracker
app.post('/count_down_tracker', function (req, res) {
  console.log("This is count_down_tracker request", req.body);
  //1. query to insert the user
  
  var countDownTracker = function(db, callback, error) {
    db.collection('users').updateOne(
      {"fb_id":"_"+req.body.fb_id, "tracks.id":req.body.track_id},//get object with fb_id
      {$pull:{"tracks.$.count":req.body.clickValue}}, //push to tracks
      function(err, result) {
        if(err !== null) {
          error(err);
        } else {
          console.log("Count DOWN Tracker");
          callback();
        }
      }
    );
  };

  console.log("***** Count DOWN Tracker into MongoDB ******");
  countDownTracker(db, function(id) {
        res.send({'success':'true'});
    }, function(message) {
        res.send({'success':'false', 'message':message});
    });
});
