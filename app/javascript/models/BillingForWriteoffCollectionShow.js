import Mustache from "mustache";

var _authenticityToken;
var _id;

var $btnAdd;
var $UpdateAmount;
var $modalUpdate
var _memberId;

var $message;
var templateErrorList;

var _cacheDom = function() {
   $btnAdd		= $("#btn-add");
   $selectMember	= $("#select-member");
   $UpdateAmount	= $(".undo");
   $modalUpdate		= $("#modal-update-transaction");
   $paymentAmount	= $("#paymentAmount");		
   $memberName		= $("#memberName");	
   $loanType		= $("#loanType");

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
	//end btnAdd
   $UpdateAmount.on("click" , function() {
	var loan_id 		= $(this).data("loan-id")
	var payment_amount	= $(this).data("payment-amount")
	var member_name		= $(this).data("member-name")
	var loan_type		= $(this).data("loan-type")
	   //alert(loan_type);
	$paymentAmount.val(payment_amount)
	$memberName.text(member_name)
	$loanType.text(loan_type)
	$modalUpdate.modal("show")
   });
}


var init  = function(config) {
  _authenticityToken = config.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };






