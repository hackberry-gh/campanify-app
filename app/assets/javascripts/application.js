//= require jquery_ujs
//= require campanify
//= require analytics
//= require maps


(function($, undefined) {
	$(document).ready(function() {
		
		// remote forms
		$("form[data-remote=true]").
		on('ajax:error', function(event, xhr, status) {
			$.campanify.processErrors($(this), event, xhr, status);
		}).
		on("ajax:success", function(event, data, status) {
			var form = $(this),
					qs = [];

			if( typeof data.meta == "object" && typeof data.meta.request_params == "object") {
				for( var q in data.meta.request_params){
					if ( q.indexOf("__") > -1 ) {
							qs.push( q + "=" + data.meta.request_params[q] );
					}
				}
			}

			location.href = (redirects[form.data('post-action')] == "show" ? 
											"/" + locale + "/" + form.data('collection') + "/" + data[form.data('find_by')] : 
											redirects[form.data('post-action')]) + 
											"?" + qs.join("&");
		});

		// language dropdown
		$("#language").change(function() {
			$.campanify.changeLocale( $(this).val() );
		});

		//delete buttons
		$("a[data-method=delete]").
		on("ajax:success", function(event, data, status) {
			location.href = data['redirect_to'] || "/";
		});

		// like button
		$("a.liking[data-remote=true]").
		on('ajax:error', function(event, xhr, status) {
			$.campanify.processErrors(event, xhr, status);
		}).
		on("ajax:success", function(event, data, status) {
			location.reload();
		});

		// post form
		if( $("form.content_post textarea").length > 0 ) {
			$("form.content_post textarea").markItUp(markitupSettings);
		}

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

		//global ajax handlers
		$(document).
		ajaxSend(function(event, jqXHR, ajaxSettings, thrownError) {
		  $.campanify.showLoading();
		}).
		ajaxStop(function(event, jqXHR, ajaxSettings, thrownError) {
		  $.campanify.hideLoading();
		}).
		ajaxError(function(event, jqXHR, ajaxSettings, thrownError) {
		  $.campanify.handle403Error(jqXHR);
		});

		//addthis
		if(typeof addthis != "undefined"){
			addthis.init();
		}
		
		
})( jQuery );