$(document).ready( function(){
	// remote forms
	$("form[data-remote=true]").
	on('ajax:beforeSend', function(event, data, status){
		$.campanify.showLoading();
	}).
	on('ajax:error', function(event, xhr, status){
		$.campanify.processErrors($(this), event, xhr, status);
	}).
	on("ajax:success", function(event, data, status){
		$.campanify.hideLoading();
		var form = $(this);
		location.href = redirects[form.data('post-action')] == "show" ? 
										"/" + locale + "/" + form.data('collection') + "/" + data[form.data('find_by')] : 
										redirects[form.data('post-action')];
	});
});