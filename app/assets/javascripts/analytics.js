(function($, undefined) {
	$.extend($.campanify,{
		drawSparklines: function () {

			function normalize(data, period) {
				var ndata = [];
				for( var i = 0 ; i < ranges[period]; i++) {
					ndata[i] = [i+1,0];
				}
				for(  var i = 0 ; i < data.length; i++) {
					ndata[data[i][0]] = data[i][1];
				}
				return ndata;
			};
			var ranges = {
				daily: 25,
				weekly: 8,
				monthly: 32,
				yearly: 13
			};

			var w = $('.page').width();
			var h = Math.round( w * 4 / 16 ) ;
			var values = $.sparklineData;
			for( type in values) {
				for( period in values[type]) {
					if(period != "total") {
						$("#" + type + ' .linechart.' + period).sparkline( 
							normalize(values[type][period], period), 
							{
								chartRangeClip: true, 
								chartRangeMinX:1, 
								chartRangeMaxX:ranges[period][0], 
								width:w, height:h
							}
						);
						$.sparkline_display_visible();	
					}
				}
			}
		},
		loadAnalytics: function() {
			$.get("/analytics/map", function(data) {
				
				var markers = [],
				geocoder = new google.maps.Geocoder(),
				mapMarkerStatus = [],
				countryIndex = 0;
				data = data['user_counts_by_country'];
				
				function addCountry() {
					if( data[countryIndex] !== undefined) { 

		        var countryCode = data[countryIndex].country;
		        geocoder.geocode({address: countryCode}, addToMap);

		        if(mapMarkerStatus[countryIndex] != google.maps.GeocoderStatus.OK &&
							mapMarkerStatus[countryIndex] != google.maps.GeocoderStatus.ZERO_RESULTS) {
		            setTimeout(addCountry, 100);
		        }

		        else if(countryIndex + 1 < data.length) {
		            countryIndex++;
		            setTimeout(addCountry, 100);
		        }
		
					}
		    }
		
				function addToMap(results, status) {
					
					if(mapMarkerStatus[countryIndex] == google.maps.GeocoderStatus.OK ||
						mapMarkerStatus[countryIndex] == google.maps.GeocoderStatus.ZERO_RESULTS)
						return;
					
					mapMarkerStatus[countryIndex] = status;
					
					if(status == google.maps.GeocoderStatus.OK) {
						for(var i = 0; i < results.length; i++) {
							if(results[i].types.indexOf('country') > -1 ) {
								var row = data[countryIndex];
								$.campanify.addMarker($.campanify.map, {
									title: row.country + ": " + row.user_count, 
									position: results[i].geometry.location
								});
								break;							
							}
						}
					}
				}
				
				$.campanify.initializeMap(
					{zoom: 1, latitude: 43.68111196292809, longitude: 12.187500000000027}, markers
				);
				
				addCountry();

			});

			$("#ranking #ranks").load("/analytics/ranking");

			$.get("/analytics/graphs", function(data) {

				$.sparklineData = data;

				$(window).resize($.campanify.drawSparklines);

				$.campanify.drawSparklines();

			});
		}
	});
})( jQuery );