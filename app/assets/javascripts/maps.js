(function($, undefined) {
	
	$.extend($.campanify,{
		
		initializeMap: function (map, markers) {

		  var map = $.campanify.map = new google.maps.Map($('#map_canvas')[0], {
		    zoom: map.zoom,
		    center: new google.maps.LatLng(map.latitude, map.longitude),
		    mapTypeId: google.maps.MapTypeId.ROADMAP
		  });
			
			for (var i in markers) {
				$.campanify.addMarker(map, markers[i]);
			}
		},
		addMarker: function(map, marker) {
			marker.map = map;
			if (marker.position.latitude && marker.position.longitude) {
				marker.position = new google.maps.LatLng(
					marker.position.latitude, 
					marker.position.longitude
				);
			}
		  google.maps.event.addListener(new google.maps.Marker(marker), 'click', function() {
				if ( $.campanify.infowindow !== undefined) {
					$.campanify.infowindow.close();
				}
				$.campanify.infowindow = new google.maps.InfoWindow({content: this.title});
		    $.campanify.infowindow.open(this.map, this);
		  });
		},
		
	});
})( jQuery );