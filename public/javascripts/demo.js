var acidworx = {
	demo : {}
};

$(function() {

    Dropzone.options.fileUploader = {
		paramName : "file",
		parallelUploads : 1,
		//acceptedFiles : "application/zip,application/octet-stream,audio/mpeg3,audio/x-mpeg-3,",
		maxFilesize : 150,
		timeout : 1000000000,
		addRemoveLinks : true,
		params : {
			token : acidworx.demo.token
		},
		url : "/upload",
		dictDefaultMessage : "Tap, click or drop files here to upload to AcidWorx.",

		init: function() {
		    this.on("addedfile", function(file) { 
	    		// push into 
	    		acidworx.demo.files.push(file.name);

	    		acidworx.demo.files2.push({
    				name : file.name,
    				status : 'added'
	    		});

	    		var current_file = acidworx.demo.files2.find(function (file) {
	    			return file.name === file.name;
	    		})

	    		console.log(current_file);

				if (acidworx.demo.mode === "validating" && $(".dropzone").hasClass("borderRed")) {
					console.log("add file -- removing red border class");
				  	$(".dropzone").removeClass("borderRed");
				}

			}),

			this.on("removedfile", function(file) {  
		    	var index = acidworx.demo.files.indexOf(file.name);
		    	acidworx.demo.files.splice(index, 1);

		    	// tell server.

		    	var current_file = acidworx.demo.files2.find(function (curr_file) {
	    			return curr_file.name === file.name;
	    		})

				current_file.status = "removed";

				var indexOfCurrFile = acidworx.demo.files2.findIndex(i => i.name === file.name);
				acidworx.demo.files2.splice(indexOfCurrFile, 1);

	    		//console.log(current_file);

		    	//console.log('Client: I have removed file ' + file.name);

		    	$.ajax({
		            url: '/api/demo/remove-file/' +  file.name,
		            type: "GET",
		            contentType: "application/json",
		            success: function(data) {
		                if (data.status == "ok" ) {
		                    // all good.
		                } else {
		                    alert("Server failed " + data.error);
		                }
		            },
		            error: function(XMLHttpRequest, textStatus, errorThrown) {
		                alert("Server failed " + textStatus);
		            }
		        });


		    	if (acidworx.demo.mode === "validating" && index === 0) {
					console.log("removing file -- adding red border class");
				  	$(".dropzone").addClass("borderRed");
				}

		    }),
		    this.on("sending", function(file) {  
		    	var index = acidworx.demo.files.indexOf(file.name);
		    	// mark file as sending
		    	//alert("upload sending");
		    	var current_file = acidworx.demo.files2.find(function (curr_file) {
	    			return curr_file.name === file.name;
	    		})

				current_file.status = "sending";
		    }),
		    this.on("success", function(file) {  
		    	var index = acidworx.demo.files.indexOf(file.name);
		    	// mark file as successful
		    	//alert("upload successful");

		    	var current_file = acidworx.demo.files2.find(function (curr_file) {
	    			return curr_file.name === file.name;
	    		})

				current_file.status = "success";
		    }),
		    this.on("canceled", function(file) {  
		    	var index = acidworx.demo.files.indexOf(file.name);
		    	// mark file as canceled
		    	//alert("upload canceled");
		    	var current_file = acidworx.demo.files2.find(function (curr_file) {
	    			return curr_file.name === file.name;
	    		})

				current_file.status = "canceled";
		    }),
		    this.on("error", function(file, errorMessage) {  
		    	var index = acidworx.demo.files.indexOf(file.name);
		    	// mark file as error
		    	//alert("upload error: " + errorMessage);
		    	var current_file = acidworx.demo.files2.find(function (curr_file) {
	    			return curr_file.name === file.name;
	    		})

				current_file.status = "failed";
		    }),
			this.on("complete", function(file, errorMessage) {  
		    	var index = acidworx.demo.files.indexOf(file.name);
		    	// mark file as complete
		    	//alert("upload complete");
		    	var current_file = acidworx.demo.files2.find(function (curr_file) {
	    			return curr_file.name === file.name;
	    		})

				current_file.status = "complete";
		    });

		 }
    };

    $("#name").change(function() {
    	acidworx.demo.name = $(this).val();
    });

    $("#artistName").change(function() {
		acidworx.demo.artistName = $(this).val();
    });

    $("#country").change(function() {
		acidworx.demo.country.code = $(this).val();
		acidworx.demo.country.text = $("#country option:selected").text();
    });

	$("#email").change(function(){
		acidworx.demo.email.value = $(this).val();
		if ($("#email").validateEmail()) {

			acidworx.demo.email.valid = true;

			$.ajax({
	            url: '/api/confirm_email_send/'+ acidworx.demo.token + '/' + $("#email").val() + '/Demo Submitter',
	            type: "GET",
	            contentType: "application/json",
	            success: function(data) {
	                if (data.status == "ok" ) {
	                    
	                } else {
	                    alert("Server failed " + data.error);
	                }
	            },
	            error: function(XMLHttpRequest, textStatus, errorThrown) {
	                alert("Server failed " + textStatus);
	            }
	        });

			$(".pageShadow").show();
			$(".confirmEmail").show();

		} else {
			console.log('invalid email');
		}
	});

	$("#emailConfirmCode").bind("enterKey",function(e){

		$.ajax({
            url: '/api/confirm_email/'+ acidworx.demo.token + '/' + $("#emailConfirmCode").val(),
            type: "GET",
            contentType: "application/json",
            success: function(data) {
                if (data.status == "ok" ) {
                	acidworx.demo.email.confimed = true;
                    $(".confirmEmail").hide();
                    $(".pageShadow").hide();
                } else {
                	acidworx.demo.email.confimed = false;
                    alert("Server failed " + data.error);
                }
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                alert("Server failed " + textStatus);
            }
        });
	});

	$("#emailConfirmButton").click(function() {
		$.ajax({
            url: '/api/confirm_email/'+ acidworx.demo.token + '/' + $("#emailConfirmCode").val(),
            type: "GET",
            contentType: "application/json",
            success: function(data) {
                if (data.status == "ok" ) {
                	acidworx.demo.email.confimed = true;
                    $(".confirmEmail").hide();
                    $(".pageShadow").hide();
                } else {
                	acidworx.demo.email.confimed = false;
                    alert("Server failed " + data.error);
                }
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                alert("Server failed " + textStatus);
            }
        });
	});

	$("#emailConfirmCode").keyup(function(e){
	    if(e.keyCode == 13) {
	        $(this).trigger("enterKey");
	    }
	});

	$("#otherLabelsRadio input[type='radio']").change(function(){
		console.log($(this).val());
		acidworx.demo.sentToOtherLabels = ($(this).val() === "1" ? true : false);
	});

	$("#sendBy input[type='radio']").change(function(){
		if($(this).val() == "upload" ) {
			$("#linkContainer").hide();

			if (acidworx.demo.loggedIn === true) {
				$("#fileUploader").show();
			} else {
				$(".noLoginUpload").show();
			}

			acidworx.demo.sendBy = "upload";
			$("#link").removeClass("borderRed");
			$(".dropzone").removeClass("borderRed");
		} else {
			$("#linkContainer").show();

			if (acidworx.demo.loggedIn === true) {
				$("#fileUploader").hide();
			} else {
				$(".noLoginUpload").hide();
			}

			acidworx.demo.sendBy = "link";
		}
	});

	$("#link").change(function () {
		acidworx.demo.linkURL = $( "#link" ).val();
		// insert a link array with objects of URL and valid

		var link = {
			URL : $( "#link" ).val(),
			valid : false
		};

		if(/^(http|https|ftp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i.test($("#link").val())) {
	    	$("#link").removeClass("borderRed");
	    	link.valid = true;
		} else {
			$("#link").addClass("borderRed");
		}

		acidworx.demo.link = link;
	});

	var demoDesc = 255;
	$("#charCountDown").html(demoDesc);
	$("#demoDesc").keypress(function () {
		$("#charCountDown").html(demoDesc - $("#demoDesc").val().length);
		//console.log($("#demoDesc").val().length);
	});

	$("#demoDesc").change(function(){
		acidworx.demo.description = $("#demoDesc").val();
	});
	
	$("#submitButton").click(function(){
		acidworx.demo.mode = "validating";
		acidworx.demo.errors = [];
		console.log(acidworx.demo);

		var status = acidworx.demo.valid();
		console.log("return status from valid: " + status);

		var incomplete_files = acidworx.demo.files2.find(function (curr_file) {
			return curr_file.status != "complete";
		});

		if ( status == true && ! incomplete_files ) {
			console.log("submit form now");
			$("#demoForm").submit();
		} else {
			//$(window).scrollTop(300);

			var errorStr = "";

			if ( incomplete_files ) {
				acidworx.demo.errors.push("Upload in-progress.");
			}

			$.each( acidworx.demo.errors, function (index, value) {
				errorStr += "<div class=error>"+value+"</div>";
			});

			$(".errors").html(errorStr);


			$(".pageError").show();
			$(".pageShadow").show();
		}
	});

	$(".closeError").click(function() {
		$(".pageError").hide();
		$(".pageShadow").hide();
	});

	var index = 1;
	$('.addLink').click(function(){
		var this_index = index + 1;

		var html = '<br><br><div id="link' + this_index + 'Container">'
		  			+ '<input id="link' + this_index + '" type="text" name="link' + this_index + '" id="link' + this_index + '" required>'
		  			+ '<label for="link' + this_index + '">Link to your demo</label>'
					+'</div><br>';
		console.log(html);
		$("#link" + index + 'Container').append(html);
		index++;
	});


	//$(window).unload(function() {
	//	console.log("bye!");
	//});

});