/*
index.js - Gradebook

Andrew Figueroa
Data Science & Systems Lab (DASSL), Western Connecticut State University

Copyright (c) 2017- DASSL. ALL RIGHTS RESERVED.
Licensed to others under CC 4.0 BY-NC-SA
https://creativecommons.org/licenses/by-nc-sa/4.0/

ALL ARTIFACTS PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

This JavaScript file provides the client-side JS code that is used by the index.html
page. The functionality provided includes accessing the REST API provided by the web
server component of the Gradebook webapp, along with providing interactivity for the
index.html webpage. 
*/

/*
Currently, a globally scoped variable is used to store login information.
 At a later point, it may be stored through a more appropriate manner, such as
 client cookies.
*/
var dbInfo = {
	"host":null, "port":null, "database":null, "user":null, "password":null,
	 "instructorid":null
};
var instInfo = { "fname":null, "mname":null, "lname": null, "dept":null };

/* 
Each instance of connInfo as a parameter in a function definition refers to an 
 object with the following keys, which are used as part of the REST API calls to
 the Gradebook server:
	"host":String, "port":Number, "database":String, "user":String,
	 "password":String, "instructorid":Number
*/


$(document).ready(function() {
	$('select').material_select(); //load dropdown boxes
	
	
	$('#btnLogin').click(function() {
		dbInfo = getDBFields();
		if (dbInfo != null) {
			var email = $('#email').val().trim();
			if (email != '') {
				serverLogin(dbInfo, email, function() {
					$('#profile').css('display', 'inline');
					popYears(dbInfo);
				});
			}
			else {
				alert('One or more fields are empty');
			}
		}
	});
	
	$('#yearSelect').change(function() {
		var year = $('#yearSelect').val();
		popSeasons(dbInfo, year);
	});
	
	$('#seasonSelect').change(function() {
		var year = $('#yearSelect').val();
		var season = $('#seasonSelect').val();
		popCourses(dbInfo, year, season);
	});
	
	$('#courseSelect').change(function() {
		var year = $('#yearSelect').val();
		var season = $('#seasonSelect').val();
		var course = $('#courseSelect').val();
		popSections(dbInfo, year, season, course);
	});
	
	$('#sectionSelect').change(function() {
		var sectionID = $('#sectionSelect').val();
		popAttendance(dbInfo, sectionID);
	});
	
	$('#logout').click(function() {
		dbInfo = null;
		instInfo = null;
		setYears(null);
		$('#profile').css('display', 'none');
		$('#loginTab').css('display', 'inline');
		$('#rosterTab, #attnTab, #gradesTab, #reportsTab').css('display', 'none');
		$('ul.tabs').tabs('select_tab', 'login');
	});
});

function getDBFields() {
	var host = $('#host').val().trim();
	var port = $('#port').val().trim();
	var db = $('#database').val().trim();
	var uname = $('#user').val().trim();
	var pw =  $('#passwordBox').val().trim();
	
	if (host === "" || port === "" || db === "" || uname === "" || pw === "")
	{
		alert('One or more fields are empty');
		return null;
	}
	
	pw = JSON.stringify(sjcl.encrypt('dassl2017', pw));
	
	var connInfo = { 'host':host, 'port':parseInt(port, 10), 'database':db,
	 'user':uname, 'password':pw };
	return connInfo;
};

function serverLogin(connInfo, email, callback) {
	//"create a copy" of connInfo with instructoremail and set to urlParams
	var urlParams = $.extend({}, connInfo, {instructoremail:email});
	$.ajax('login', {
		dataType: 'json',
		data: urlParams ,
		success: function(result) {
			dbInfo.instructorid = result.instructor.id;
			instInfo = { fname:result.instructor.fname, 
			mname:result.instructor.mname, lname:result.instructor.lname,
			dept:result.instructor.department };
			
			$('#loginTab').css('display', 'none');
			$('#rosterTab, #attnTab, #gradesTab, #reportsTab').css('display', 'inline');
			$('ul.tabs').tabs('select_tab', 'attendance');
			
			//Array.prototype.join is used because in JS: '' + null = 'null'
			var instName = [instInfo.fname, instInfo.mname, instInfo.lname].join(' ');
			$('#instName').html(instName);
			
			callback();
		},
		error: function(result) {
			alert('Login failed - ensure all fields are correct');
			console.log(result);
		}
	});
};

function popYears(connInfo) {
	$.ajax('years', {
		dataType: 'json',
		data: connInfo,
		success: function(result) {
			var years = '';
			for (var i = 0; i < result.years.length; i++) {
				years += '<option value="' + result.years[i] + '">' +
				 result.years[i] + '</option>';
			}
			setYears(years);
		},
		error: function(result) {
			alert('Error while retrieving years - ensure DB info is correct');
			console.log(result);
		}
	});
};

function popSeasons(connInfo, year) {
	var urlParams = $.extend({}, connInfo, {year:year});
	$.ajax('seasons', {
		dataType: 'json',
		data: urlParams,
		success: function(result) {
			var seasons = '';
			for (var i = 0; i < result.seasons.length; i++) {
				seasons += '<option value="' + result.seasons[i].seasonorder +
				 '">' + result.seasons[i].seasonname + '</option>';
			}
			setSeasons(seasons);
		},
		error: function(result) {
			alert('Error while retrieving seasons');
			console.log(result);
		}
	});
};

function popCourses(connInfo, year, seasonorder) {
	var urlParams = $.extend({}, connInfo, {year:year, seasonorder:seasonorder});
	$.ajax('courses', {
		dataType: 'json',
		data: urlParams,
		success: function(result) {
			var courses = '';
			for (var i = 0; i < result.courses.length; i++) {
				courses += '<option value="' + result.courses[i] + '">' + 
				 result.courses[i] + '</option>';
			}
			setCourses(courses);
		},
		error: function(result) {
			alert('Error while retrieving courses');
			console.log(result);
		}
	});
};

function popSections(connInfo, year, seasonorder, coursenumber) {
	var urlParams = $.extend({}, connInfo, {year:year, seasonorder:seasonorder,
	 coursenumber:coursenumber});
	$.ajax('sections', {
		dataType: 'json',
		data: urlParams,
		success: function(result) {
			var sections = '';
			for (var i = 0; i < result.sections.length; i++) {
				sections += '<option value="' + result.sections[i].sectionid +
				 '">' + result.sections[i].sectionnumber + '</option>';
			}
			setSections(sections);
		},
		error: function(result) {
			alert('Error while retrieving sections');
			console.log(result);
		}
	});
};

function popAttendance(connInfo, sectionid) {
	var urlParams = $.extend({}, connInfo, {sectionid:sectionid});
	$.ajax('attendance', {
		dataType: 'html',
		data: urlParams,
		success: function(result) {
			var attnTable = result;
			if (attnTable.substring(0, 7) === '<table>') {
				attnTable = '<table class="striped" style="display:block;' +
				 'margin:auto;overflow-x:auto">' + attnTable.substring(7);
			}
			else {
				console.log('WARN: Unable to style attendance table;' +
				 'first 7 chars did not match "<table>"');
			}
			$('#attendanceData').html(attnTable);
		},
		error: function(result) {
			alert('Error while retrieving attendance data');
			resetAttendance();
			console.log(result);
		}
	});
};

function setYears(htmlText) {
	var content = '<option value="" disabled="true" selected="true">' +
	 'Choose year</option>' + htmlText;
	$('#yearSelect').html(content);
	$('#yearSelect').prop('disabled', htmlText == null);
	$('#yearSelect').material_select(); //reload dropdown
	
	setSeasons(null); //reset dependent fields
};

function setSeasons(htmlText) {
	var content = '<option value="" disabled="true" selected="true">' +
	 'Choose season</option>' + htmlText;
	$('#seasonSelect').html(content);
	$('#seasonSelect').prop('disabled', htmlText == null);
	$('#seasonSelect').material_select(); //reload dropdown
	
	setCourses(null); //reset dependent fields
};

function setCourses(htmlText) {
	var content = '<option value="" disabled="true" selected="true">' +
	 'Choose course</option>' + htmlText;
	$('#courseSelect').html(content);
	$('#courseSelect').prop('disabled', htmlText == null);
	$('#courseSelect').material_select(); //reload dropdown
	
	setSections(null); //reset dependent fields
};

function setSections(htmlText) {
	var content = '<option value="" disabled="true" selected="true">' +
	 'Choose section</option>' + htmlText;
	$('#sectionSelect').html(content);
	$('#sectionSelect').prop('disabled', htmlText == null);
	$('#sectionSelect').material_select(); //reload dropdown
	
	resetAttendance(); //reset dependent fields
};

function resetAttendance() {
	$('#attendanceData').html('');
};
