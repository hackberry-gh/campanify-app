// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function(){
	$("form[data-remote=true]").on('ajax:error', function(event, xhr, status){
		var form = $(this);
		var responseObject = $.parseJSON(xhr.responseText);

		errorList = $('<ul />');

		$.each(responseObject.errors, function(field,errors){
			var fieldName = form.find("label[for=" + form.data('prefix') + "_" + field + "]").text();
			errorList.append('<li>' + fieldName + ' ' + errors.join(", ") + '</li>');
		});

		form.find('#errors').html(errorList);
	}).on("ajax:success", function(event, xhr, status){
		location.href = redirects[$(this).data('post-action')];
	});
});