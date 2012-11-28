// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs

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
		processErrors: function(form, event, xhr, status) {
			$.campanify.hideLoading();
			
			var responseObject = $.parseJSON(xhr.responseText),
			 		errorList = $('<ul />'),
					count = 0,
					errTitle = errorSentence.replace("$count",count).
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
			if (marker.position) {
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
			$("iframe.video").css({height: $("iframe.video").width()*9/16});
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

	$(document).ready(function() {
		
		// remote forms
		$("form[data-remote=true]").
		on('ajax:beforeSend', function(event, data, status) {
			$.campanify.showLoading();
		}).
		on('ajax:error', function(event, xhr, status) {
			$.campanify.processErrors($(this), event, xhr, status);
		}).
		on("ajax:success", function(event, data, status) {
			$.campanify.hideLoading();
			var form = $(this);
			location.href = redirects[form.data('post-action')] == "show" ? 
											"/" + locale + "/" + form.data('collection') + "/" + data[form.data('find_by')] : 
											redirects[form.data('post-action')];
		});

		// language dropdown
		$("#language").change(function() {
			$.campanify.changeLocale( $(this).val() );
		});

		//delete buttons
		$("a[data-method=delete]").
		on('ajax:beforeSend', function(event, data, status) {
			$.campanify.showLoading();
		}).
		on("ajax:success", function(event, data, status) {
			$.campanify.hideLoading();
			location.href = data['redirect_to'] || "/";
		});

		// like button
		$("a.liking[data-remote=true]").
		on('ajax:beforeSend', function(event, data, status) {
			$.campanify.showLoading();
		}).
		on('ajax:error', function(event, xhr, status) {
			$.campanify.processErrors(event, xhr, status);
		}).
		on("ajax:success", function(event, data, status) {
			location.reload();
		});

		// post form
		if( $("form.content_post textarea").length > 0 )
			$("form.content_post textarea").markItUp(markitupSettings);
		
		// auto select fields
		$('.auto_select').focus(function() {
			var $this = $(this);

			$this.select();

			window.setTimeout(function() {
				$this.select();
				}, 1);

				// Work around WebKit's little problem
				$this.mouseup(function() {
					// Prevent further mouseup intervention
					$this.unbind("mouseup");
					return false;
				});
			})
		});
		
})( jQuery );