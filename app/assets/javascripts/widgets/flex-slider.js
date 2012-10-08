//= require ./flex-slider/jquery.flexslider-min.js

$(window).load(function() {
 
	$(".flexslider iframe.vimeo").each(function(){
		// Vimeo API nonsense
		function addEvent(element, eventName, callback) {
	    if (element.addEventListener) {
	      element.addEventListener(eventName, callback, false)
	    } else {
	      element.attachEvent(eventName, callback, false);
	    }
	  }

	  function ready(player_id) {		
	    var froogaloop = $f(player_id);

	    froogaloop.addEvent('play', function(data) {
	      $('.flexslider').flexslider("pause");
	    });
	    froogaloop.addEvent('pause', function(data) {
	      $('.flexslider').flexslider("play");
	    });
	  }
	
  	var player = this;
  	$f(player).addEvent('ready', ready);	  
	
		// Call fitVid before FlexSlider initializes, so the proper initial height can be retrieved.
	  $(".flexslider")
	    .fitVids()
	    .flexslider({
	      animation: "slide",
	      useCSS: false,
	      animationLoop: true,
	      smoothHeight: true,
	      before: function(slider){
	        $f(player).api('pause');
	      }
	  });
	});
 
});