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
//= require_directory .

(function($, undefined) {
	var campanify;
	$.campanify = campanify = {
		changeLocale: function(locale){
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

		}
	};

	$(document).ready( function(){
		$("#language").change(function(){
			campanify.changeLocale( $(this).val() );
		});
	});

})( jQuery );