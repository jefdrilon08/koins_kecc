import Mustache from "mustache";

var _authenticityToken;
var _id;

var $btnAdd;
var _memberId;

var $message;
var templateErrorList;

var _cacheDom = function() {
   $btnAdd		= $("#btn-add");
   $selectMember	= $("#select-member");

   $message  = $(".message");

};

var _bindEvents = function() {
   $btnAdd.on("click", function() {
     _memberId = $selectMember.val();
     _id = $(this).data("id");	  

     var data = {
     	id: _id,
	member_id: _memberId,
	authenticity_token: _authenticityToken
     }; 
     $selectMember.prop("disabled", true);
 
     $.ajax({
	url: "/api/v1/billing_for_writeoff_collection/add_member",
	method: 'POST',
	data: data,
	success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );
        
        window.location.reload();
      	},
	error: function(response) {
        var errors  = [];

        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          errors  = ["Something went wrong"]
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );
          $selectMember.prop("disabled", false);
        }
      }
     });

	   
  });
}


var init  = function(config) {
  _authenticityToken = config.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };






