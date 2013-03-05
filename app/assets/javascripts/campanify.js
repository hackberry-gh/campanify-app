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

				error = {"errors":{"":[t.errors.general]}};
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
			var errors = xhr.status == 422 ? campanify.parseErrors(xhr).errors : 
					{"": [t.errors.general]},
			 		errorList = $('<ul />'),
					count = 0,
					errTitle = "";					
			
			$.each(errors, function(field, errors) {
				var fieldName = $.campanify.humanizeField(form, field);
				errorList.append('<li>' + fieldName + ' ' + errors.join(", ") + '</li>');
				count++;
			});

			errTitle = t.errors.template.replace("$count",count).
				replace("$resource",form.data('translated-member'));
			
			errorList.prepend($("<h3>"+errTitle+"</h3>"));		
			

			form.find('#error_explanation').html(errorList).show();
		},
		resizeVideos: function() {
			$("iframe.video").css({
				height: $("iframe.video").width()*9/16
			});
		},
	};
})( jQuery );