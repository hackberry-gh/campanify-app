$(document).ready(function(){

	$("form#open-inviter").on('submit', function(e) {
		e.preventDefault();
		$.campanify.showLoading();
		var form = $(e.target);
		switch( $("#open_inviter_step").val() ){
			case "1":
			$("#error_explanation").remove();
			$.ajax({
				type: "POST",
				url: "https://openinviter.herokuapp.com/contacts",
				data: {
					email: $("#open_inviter_email").val(),
					password: $("#open_inviter_password").val(),
					provider: $("#open_inviter_provider").val()
				},
				dataType: "json",
				error: function(event, xhr, status){
					$.campanify.hideLoading();
					form.prepend('<div id="error_explanation">An error occured, please try again later</div>');

				},
				success: function(data){
					$.campanify.hideLoading();
					if(data.errors.length == 0){
						$("#open_inviter_step").val(2);
						$("form#open-inviter #contacts").hide();
						$("form#open-inviter #invitations").show();
						for( var i in data.contacts){
							$("#open_inviter_contacts").append('<option value="'+data.contacts[i]+'">'+i+'</option>');
						}
					}else{
						var errors =  [];
						for(var i in data.errors){
							errors.push(data.errors[i]);
						}
						form.prepend('<div id="error_explanation">'+errors.join(", ")+'</div>')
					}
				}

			});
			break;
			case "2":

				$.ajax({
					url: "/users/invitation/send",
					type: "POST",
					data: {
						contacts: $("#open_inviter_contacts").val()
					},
					error: function(xhr, status, error){
						$.campanify.hideLoading();
						form.prepend('<div id="error_explanation">'+t.errors.general+'</div>');
					
					},
					success: function(data) {
						$.campanify.hideLoading();
						$("form#open-inviter").replaceWith($("<p>" + data.invitations.length + 
							" " + t.widgets.open_inviter.success+"</p>"))

					}
				})

			break;

		}

	});

});