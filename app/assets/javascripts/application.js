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
//= require demo

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
		initializeMap: function (latitude, longitude) {

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

		},
		resizeVideos: function() {
			$("iframe.video").css({height: $("iframe.video").width()*9/16});
		}
	};
})( jQuery );