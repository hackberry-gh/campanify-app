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
//= require ./markitup/jquery.markitup.js
//= require ./markitup/sets/markdown/set.js
//= require ./widgets/jquery.flexslider-min.js

(function($, undefined) {
	var campanify;
	$.campanify = campanify = {
		showLoading: function(){ $("#spinner_container").show(); },
		hideLoading: function(){ $("#spinner_container").hide(); },		
		changeLocale: function(locale) {
			var qs = location.href.
												replace(location.pathname,'').
												replace(location.host,'').
												replace(location.protocol,'').
												replace('//','');

			var parts = location.pathname.split("/");
			if ( parts[1] == parts[1].match(/\w{2}/) || parts[1] == parts[1].match(/\w{2}-\w{2}/) ){
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
			var responseObject = $.parseJSON(xhr.responseText);

			var errorList = $('<ul />');
			var count = 0;
			$.each(responseObject.errors, function(field,errors){
				var fieldName = $.campanify.humanizeField(form, field);
				errorList.append('<li>' + fieldName + ' ' + errors.join(", ") + '</li>');
				count++;
			});

			errorList.prepend($("<h3>"+errorSentence.replace("$count",count).
																replace("$resource",form.data('translated-member'))+
													"</h3>"));		

			form.find('#error_explanation').html(errorList).show();
		},
		initializeMap: function (map, markers) {

		  var map = new google.maps.Map(document.getElementById('map_canvas'), {
		    zoom: map.zoom,
		    center: new google.maps.LatLng(map.latitude, map.longitude),
		    mapTypeId: google.maps.MapTypeId.ROADMAP
		  });
			
			for (var i in markers) {
				var markerData = markers[i];
				markerData.map = map;
				markerData.position = new google.maps.LatLng( markerData.position.latitude, 
																											markerData.position.longitude);
		  	var marker = new google.maps.Marker(markerData);
		
			  google.maps.event.addListener(marker, 'click', function() {
					if ( $.campanify.infowindow !== undefined){
						$.campanify.infowindow.close();
					}
					$.campanify.infowindow = new google.maps.InfoWindow({content: this.title});
			    $.campanify.infowindow.open(this.map, this);
			  });
			}

		},
		resizeVideos: function() {
			$("iframe.video").css({height: $("iframe.video").width()*9/16});
		},
		drawSparklines: function () {
			var defaultXValues = {
				hourly: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
				daily: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31],
				weekly: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52],
				monthly: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
			}
			var w = $('.page').width();
			var h = Math.round( w * 4 / 16 ) ;
			var values = $.campanify.sparklineValues;
			for( type in values){
				for( period in values[type]){
					if(period != "total"){
						var xValues,yValues;
						if (values[type][period]["y"].length > 0) {
							yValues = values[type][period]["y"];
							xValues = values[type][period]["x"];					
						}else{
							yValues = [];
							xValues = defaultXValues[period];
							for(var i = 0; i< xValues.length; i++){
								yValues.push(0);
							}
						}
						$("#" + type + ' .linechart.' + period).sparkline(yValues, {xvalues: xValues, width: w + "px", height: h + "px"});
					}

				}
			}
		},
		loadAnalytics: function() {
			$.get("/analytics/map", function(data) {
				var markers = [];
				for( var i = 0; i < data['user_counts_by_country'].length; i++){
					var row = data['user_counts_by_country'][i];
					if (row.meta.location !== undefined){
						markers.push({title: row.country + " " + row.user_count, 
																position:{
																	latitude: row.meta.location.lat, 
																	longitude: row.meta.location.lng
																}});
					}										
				}
				$.campanify.initializeMap(
					{zoom: 1, latitude: 43.68111196292809, longitude: 12.187500000000027},
					markers
				);
			});

			$("#ranking #ranks").load("/analytics/ranking");

			$.get("/analytics/graphs", function(data) {

				var periodMaximums,periodToName,values,drawSparklines;

				periodMaximums = {
					hourly: 25,
					daily: 32,
					weekly: 53,
					monthly: 13
				}
				periodToName = {
					hourly: "hour",
					daily: "day",
					weekly: "week",
					monthly: "month"			
				}
				
				values = {};
				
				// map values
				for( var type in data ){		
					values[type] = {};
					for( var period in data[type] ){
						values[type][period] = period == "total" ? data[type][period] : {x:[], y:[]};
						for( var i in data[type][period]){
							var row = data[type][period][i];

							if (period == "total") {
								// do nothing
							} else {
								for(var x = 1; x < periodMaximums[period]; x++){
									values[type][period]["x"].push(x);
									values[type][period]["y"].push( Number(row[periodToName[period]]) == x ? Number(row[type]) : 0 );																			
								}
							}
						}
					}
				}

				// save values
				$.campanify.sparklineValues = values;

				$(window).resize(function(){
					$.campanify.drawSparklines();
				});

				$.campanify.drawSparklines();

			});
		}
	};
})( jQuery );