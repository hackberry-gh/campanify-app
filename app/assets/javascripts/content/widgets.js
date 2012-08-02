// REMOTE FORMS
$(document).ready(function(){
	$("form[data-remote=true]").on('ajax:error', function(event, xhr, status){
		var form = $(this);
		var responseObject = $.parseJSON(xhr.responseText);

		var errorList = $('<ul />');
		var count = 0;
		$.each(responseObject.errors, function(field,errors){
			var fieldName = form.find("label[for$=_"  + field + "]").text();
			errorList.append('<li>' + fieldName + ' ' + errors.join(", ") + '</li>');
			count++;
		});

		errorList.prepend($("<h3>"+errorSentence.replace("$count",count).
															replace("$resource",form.data('translated-member'))+
												"</h3>"));		

		form.find('#error_explanation').html(errorList).show();
	}).on("ajax:success", function(event, data, status){
		var form = $(this);
		location.href = redirects[form.data('post-action')] == "show" ? "/" + form.data('collection') + "/" + data[form.data('find_by')] : 
										redirects[form.data('post-action')];
	});
});