$(document).ready(function(){
	$.campanify.initializeMap = function (latitude, longitude) {

	  var latLng = new google.maps.LatLng(latitude, longitude);	

	  var map = new google.maps.Map(document.getElementById('map_canvas'), {
	    zoom: 8,
	    center: latLng,
	    mapTypeId: google.maps.MapTypeId.ROADMAP
	  });
	  var marker = new google.maps.Marker({
	    position: latLng,
	    title: 'Venue',
	    map: map
	  });

	}
});