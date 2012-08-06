
$(document).ready( function(){
	
	// language dropdown
	$("#language").change(function(){
		campanify.changeLocale( $(this).val() );
	});
	
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
	
	// like button
	$("a.liking[data-remote=true]").
	on('ajax:beforeSend', function(event, data, status){
		$.campanify.showLoading();
	}).
	on('ajax:error', function(event, xhr, status){
		$.campanify.processErrors(event, xhr, status);
	}).
	on("ajax:success", function(event, data, status){
		location.reload();
	});
	
	// post form
	$("textarea").markItUp(mySettings);
	
});