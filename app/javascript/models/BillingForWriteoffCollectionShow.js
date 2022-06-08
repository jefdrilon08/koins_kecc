import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";
import select2 from 'select2';

var _authenticityToken;
var _id;

var $btnAdd;
var $btnApprove;
var $btnConfirmProcess; 
var $UpdateAmount;
var $modalUpdate;
var $modalApproveTransaction;


var _loanId;
var _memberId;

var $message;
var templateErrorList;

var _cacheDom = function() {
   $btnAdd		= $("#btn-add");
	
   $btnConfirmAmount	= $("#btn-confirm-amount")
   $btnApprove		= $("#btn-approve");
   $btnConfirmProcess   = $("#btn-confirm-process");
   $selectMember	= $("#select-member");
   $UpdateAmount	= $(".undo");
   $modalUpdate		= $("#modal-update-transaction");
   $modalApproveTransaction = $("#modal-approve-transaction");
   $paymentAmount	= $("#paymentAmount");		
   $memberName		= $("#memberName");
   $memberId		= $("#memberId");
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
	_loanId 		= $(this).data("loan-id")
	var payment_amount	= $(this).data("payment-amount")
	var member_name		= $(this).data("member-name")
	var loan_type		= $(this).data("loan-type")
	var member_id		= $(this).data("member-id")

	   //alert(member_id);
	$paymentAmount.val(payment_amount)
	$memberName.text(member_name)
	$loanType.text(loan_type)
	$memberId.text(member_id)
	$modalUpdate.modal("show")

   });

   $btnConfirmAmount.on("click", function() {
	_paymentAmount	= $paymentAmount.val()	     
	_id 		= $(this).data("id");	
	_memberId	= $memberId.text()

	   //alert($memberId.text());
	   var data = {
		id: _id,
		member_name: $memberName.text(),
		member_id: _memberId,   
		loan_id: _loanId,   
		payment_amount: _paymentAmount,
		authenticity_token: _authenticityToken
	   	};
      $.ajax({
      url: "/api/v1/billing_for_writeoff_collection/update_amount",
      method: 'POST',
      data: data,
      success: function(response) {
	$message.html(
          "Success! Redirecting..."
        );
        
        window.location.reload();
      },
      error: function(response) {
        errors = [];
	alert(JSON.parse(response.responseText).full_messages)
        try {
          errors = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          errors.push("Something went wrong");
          console.log(response);
        }

        $message.html(
          Mustache.render(
           
          )
        );
    }
    }); 
   });

   $btnApprove.on("click", function() {
     _id = $(this).data("id");
	   //alert(_id);
	$modalApproveTransaction.modal("show");
   });

   $btnConfirmProcess.on("click", function() {
     var data = {
       id: _id,
       authenticity_token: _authenticityToken
     };
	   //alert(_id);
     $btnConfirmProcess.prop("disabled", true);
     $message.html("Loading...");

    console.log(data);
    $.ajax({
      url: "/api/v1/billing_for_writeoff_collection/approve",
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Redirecting...");
        window.location.href="/billing_for_writeoff_collections";
      },
      error: function(response) {
        console.log(response);
        var errors  = [];
        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          errors  = ["Something went wrong"];
          console.log(err);
        } finally {
          console.log(errors);
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $btnConfirmProcess.prop("disabled", false);
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






