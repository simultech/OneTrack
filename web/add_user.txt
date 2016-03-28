add user
{
  "fb_id": 111,   //FB id - unique
  "name": "John Snow"
  "tracks": [] //by default emoty array
}
return success
// create_tracker - Create a tracker
{
	'fb_id':111
	'name': 'string',
	'maxCount': 4,
}
returns: success and id generated on server
// get_trackers - Get trackers for a user
	params: user_id
	returns: [track, track, track]
// edit_tracker - Edit a tracker
	pararms: user_id, track_id, name, maxCount
	returns: success
// delete_tracker - Delete a tracker
	params: user_id, track_id
	returns: succes
// count_up_tracker - Add a count for a tracker
	params: user_id, track_id, clickValue  //clicks addobject:clickvalue
	returns: success
// count_down_tracker - Remove a count for a tracker
	params:user_id, track_id    //clicks remove last one
	returns: success



//to run server in terminal
1st window: mongod
2nd window: cd /Users/nurmerey/Dropbox/ANDREW_NURKA_SHARED/OneTrack/web 
and : node app.js
