//= require active_admin/base
//= require_directory ./ace

$(document).ready(function(){
	var editor = null;
	var current_textarea = null;

	if ( $("textarea.code").length > 0 && navigator.userAgent.match(/mobile/i) === null){
		var textarea = $("textarea.code").first();
		var id = textarea.attr("id") + "_ace";
		var div = $('<div id=\"' + id + '"></div>').insertAfter(textarea);
		var editor = ace.edit(id);
		editor.getSession().setValue(textarea.val());
		editor.setTheme("ace/theme/monokai");
		editor.session.setUseWorker(false);
    editor.getSession().setMode("ace/mode/" + textarea.data('mode'));
		editor.setHighlightSelectedWord(true);
		editor.setHighlightActiveLine(false);
		editor.setFadeFoldWidgets(false);
		textarea.hide();
		current_textarea = textarea;	
		editor.getSession().on('change', function(){
		  current_textarea.val(editor.getSession().getValue());
		});	
	}

	$(".language-selection li a").click(function(){
		var id = $(this).attr('href');
		$(".language-fields").hide();
		$(id).show();
		$(".language-selection li a.active").removeClass('active');
		$(this).addClass('active');
		var textarea = $(id + " textarea.code");
		if (textarea.length > 0) {
			$(".ace_editor").insertAfter(textarea);
			textarea.hide();
			// current_textarea.val(editor.getSession().getValue());
			current_textarea = textarea;
			editor.getSession().setValue(textarea.val());
		}
		return false;
	});

	$(".language-selection li a:first").click();
	
	function on_range_change(elm){
		var target_id = $(elm).attr('id')+"_price";
		var target = $("#"+target_id);
		var multiplier = target.data('multiplier');
		var value = $(elm).val();
		var html_value = "";
		switch( target_id ){
			case "campaign_app_ps_web_price":
			case "campaign_app_ps_worker_price":
			// var initialCost = false;
			// $('input[type=range]').each(function(){
			// 	if ( this!=elm && $(elm).val() > 0 ){
			// 		initialCost = true;
			// 	}
			// });
			// var cost = initialCost ? value : (value>0 ? value-1 : 0);
			// html_value = "#"+value+" $"+cost*multiplier;
			html_value = "#"+value+" $"+value*multiplier;			
			break;			
			default:
			html_value = "#"+value;
			break;
		}
		calculate_total();
		target.html(html_value);
	}

	$('input[type=range]').unbind('change').bind('change',function(){on_range_change(this);});

	$('input[type=range]').each(function(){
		var target_id = $(this).attr('id')+"_price";
		var target = $("#"+target_id);
		$(this).parent('li').append(target);
		on_range_change(this);
	});
	
	function calculate_total(){
		// processes
		var multiplier = $("#campaign_app_ps_web_price").data('multiplier');
		var total = ( Number($("#campaign_app_ps_web").val()) + Number($("#campaign_app_ps_worker").val()) ) * multiplier;
		// var db_cost = Number($("#campaign_app_mongolab_plan_input input[type=radio]:checked").parent("label").text().match(/\$\d*/)[0].replace("$",""));
		// total += db_cost;
		total -= 35; // heroku gives first 7200 for free
		
		// addons
		$("input.addon:checked").each(function(){
			var addon_val = parseFloat($(this).parent("label").text().split("$")[1]);
			total += addon_val;
		});
		
		$("#campaign_app_ps_total_price").html("$"+total);
	}
	
	$("input.addon").click(calculate_total);
	
	calculate_total();
	
	function setUriRemoveAction(){
		$(".uri_remove").unbind('click').bind('click',function(){
			var id = $(this).attr('id').replace('uri_remove_','');
			$('#uri_'+id).remove();
			$(this).remove();
			var label = $(".campaign_app_domains_label");
			console.log(label.css('padding-bottom'))
			var new_padding = Number(label.css('padding-bottom').replace('px','')) - 45;
			label.css({'padding-bottom':new_padding});			
			return false;
		});
	}
	
	setUriRemoveAction();
	
	$(".uri_add").click(function(){
		var ot = $(this).prev();
		if(ot.val()!=="") {
			var new_input = ot.clone();
			var id = Number(new_input.attr('id').replace("uri_",""))+1;
			new_input.attr('id',"uri_"+id);
			new_input.val('');
			new_input.insertBefore($(this));
			$('<button class="uri_remove" id="uri_remove_'+(id-1)+'">x</button>').insertBefore(new_input);
			setUriRemoveAction();
			var label = $(".campaign_app_domains_label");
			var new_padding = Number(label.css('padding-bottom').replace('px','')) + 45;
			label.css({'padding-bottom':new_padding});
		}
		return false;
	});
	
	$("li.choice input[type=checkbox]").change(checker);
	function checker(){
		c = $(this);
		if( c.is(':checked') ){
			c.parent("label").addClass('checked');
		}else{
			c.parent("label").removeClass('checked');			
		}
	}
	$("li.choice input[type=checkbox]").each(checker);
	
	$("li.choice input[type=radio]").change(optioner);
	function optioner(){
		c = $(this);
		c.parents("li").find("label").removeClass("checked")
		if( c.is(':checked') ){
			c.parent("label").addClass('checked');
		}
	}
	$("li.choice input[type=radio]").each(checker);
	
	$("div#search_sidebar_section form").submit(function(){
		location.href = $(this).attr("action") + "?" + $(this).serialize();
		return false;
	})
	
	$(".array_field.add_more").click(function(){
		var container = $(this).prev("ul");
		var last = container.find("li:last");
		var clone = last.clone();
		
		var current_id = last.find("input").attr("id").split("_");
		current_id = parseInt(current_id[current_id.length-1]);		
		var next_id = current_id + 1;

		
		var label_for = last.find("label").attr("for").replace("_" + current_id, "_" + next_id);
		var label_text = last.find("label").text().replace(current_id, next_id);		
		var input_id = last.find("input").attr("id").replace("_" + current_id, "_" + next_id);
		var li_id = last.attr("id").replace("_" + current_id, "_" + next_id);
		
		clone.attr("id",li_id).addClass("clone");
		clone.find("label").attr("for",label_for).text(label_text);
		clone.find("input").attr("id",input_id).val("");
		
		container.append(clone);
		return false;
	})
	$(".array_field.remove_clone").click(function(){
		$(this).prevAll("ul").find("li:last.clone").remove();
		return false;
	});
	
	// help menu item
	if ( !$("body").hasClass("docs_namespace") ) { 
		$("#header ul.header-item").append($('<li id="docs"><a href="/docs/welcome">Docs</a></li>'));
	} else {
		$("#header ul.header-item li#dashboard a").text("Adminstration").attr("href", "/admin");
	}
	
	//trans clone
	$("#translations_cloning a#clone").click(function(){
		window.location.href = "/admin/translations/clone?from=" + 
			$("#translations_cloning select#from").val() + 
			"&to=" + $("#translations_cloning select#to").val();
	});
	

});

