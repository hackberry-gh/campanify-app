(function($, undefined) {
	var campanify;
	$.campanify = campanify = {
		showLoading: function() { $("#spinner_container").show(); },
		hideLoading: function() { $("#spinner_container").hide(); },		
		changeLocale: function(locale) {
			var qs = location.href.
												replace(location.pathname,'').
												replace(location.host,'').
												replace(location.protocol,'').
												replace('//','');

			var parts = location.pathname.split("/");
			if ( parts[1] == parts[1].match(/\w{2}/) || parts[1] == parts[1].match(/\w{2}-\w{2}/) ) {
				parts.shift();
				parts.shift();			
				location.href = "/" + locale + "/" + parts.join("/") + qs;
			}else{
				location.href = "/" + locale + location.pathname + qs;			
			}
		},
		humanizeField: function(form, field) {
			return form.find("#" + form.data('member') + "_" + field).data('label') ||
			form.find("label[for$=_"  + field + "]").text() ||
			field;
		},
		parseErrors: function (error) {
			try{
				if (typeof error == "object" && error.responseText) {
					error = JSON.parse(error.responseText);
				} else if (typeof error == "string") {
					error = JSON.parse(error);
				}
			}catch(err){
				error = {error: error};
			}
			return error;
		},
		handle403Error: function (error) {
			error = campanify.parseErrors(error);

			if (error.error == "Unauthorized") {
				window.location.href = "/users/sign_in"
			}
		},
		processErrors: function(form, event, xhr, status) {
			var responseObject = campanify.parseErrors(xhr),
			 		errorList = $('<ul />'),
					count = 0,
					errTitle = t.errors.template.replace("$count",count).
						replace("$resource",form.data('translated-member'));					
						
			$.each(responseObject.errors, function(field,errors) {
				var fieldName = $.campanify.humanizeField(form, field);
				errorList.append('<li>' + fieldName + ' ' + errors.join(", ") + '</li>');
				count++;
			});
			
			errorList.prepend($("<h3>"+errTitle+"</h3>"));		

			form.find('#error_explanation').html(errorList).show();
		},
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
		resizeVideos: function() {
			$("iframe.video").css({
				height: $("iframe.video").width()*9/16
			});
		},
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
	};
})( jQuery );