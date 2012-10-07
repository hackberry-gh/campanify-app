
$(document).ready( function(){
	
	// language dropdown
	$("#language").change(function(){
		$.campanify.changeLocale( $(this).val() );
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
	
	//delete buttons
	$("a[data-method=delete]").
	on('ajax:beforeSend', function(event, data, status){
		$.campanify.showLoading();
	}).
	on("ajax:success", function(event, data, status){
		$.campanify.hideLoading();
		location.href = data['redirect_to'] || "/";
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
	if( $("form.content_post textarea").length > 0 )
		$("form.content_post textarea").markItUp(markitupSettings);
	
	// youtube responsive
	$(window).resize(function(){
		$.campanify.resizeVideos();
	});
	
	$("#user_country option[value=" + country + "]").attr('selected',true);
	
	// analytics
	if( $(".page#analytics").length > 0 ) {
		
		$("#graphs nav > a").click(function(){
			var period = $(this).attr('href').replace("#","");
			$("#graphs nav > a").removeClass("active");
			$(this).addClass("active");			
			$(".linechart").hide();
			$(".linechart." + period).show();
			$.campanify.drawSparklines();
			return false;
		});
		
		$("#graphs nav span > a").click(function(){
			var type = $(this).attr('href').replace("#","");
			$("#graphs nav span > a").removeClass("active");
			$(this).addClass("active");
			$("#graphs > article").hide();
			$("#graphs > article#" + type).show();
			$.campanify.drawSparklines();
			return false;
		});
		
	
		$.campanify.loadAnalytics();
		
		$("#graphs nav > a:first").click();
		$("#graphs nav span > a:first").click();		
	}
	
});