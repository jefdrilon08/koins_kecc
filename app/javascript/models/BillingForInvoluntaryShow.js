import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var _authenticityToken;
var _id;

var $btnDelete;
var $btnConfirmDelete;
var $modalDelete;

var $btnApproved;
var $btnConfirmApproved;
var $modalApproved;


var $btnSaveParticularTransfer;
var $btnSaveParticularPayments;
var $inputParticularSavings;
var $inputParticularPayments;



var $btnAdd;
var _memberId;
var $selectMember;


var currentMember           = "";
var currentMemberId         = "";
var $message;
  templateErrorList = $("#template-error-list").html();

var _cacheDom = function() {
  console.log(_id);
 
  $btnAdd             = $("#btn-add");	
  $selectMember       = $("#select-member");

  $btnSaveParticularTransfer = $("#btn-add-particular-trans");
  $inputParticularSavings = $("#particular-transfer-savings");

  $btnSaveParticularPayments = $("#btn-add-particular-lp");
  $inputParticularPayments = $("#particular-transfer-loan-payments");

  $btnApproved = $("#btn-approve");
  $btnConfirmApproved = $("#btn-confirm-approved");
  $modalApproved = new bootstrap.Modal(document.getElementById("modal-approve"));
  


  $message            = $(".message");
  templateErrorList = $("#template-error-list").html();
};

var _bindEvents = function() {
  $btnApproved.on("click", function(){
    $modalApproved.show();
  });

  $btnConfirmApproved.on("click",function(){
    var data = {
      id: _id,
      authenticity_token: _authenticityToken
    }

    $btnConfirmApproved.prop("disabled", true);

    $.ajax({
      url: "/api/v1/billing_for_involuntary/approve",
      data: data,
      method: "POST",
      success: function(response) {
        $message.html("Success! Redirecting...");
        window.location.href="/billing_for_involuntary";
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
          $btnConfirmApproved.prop("disabled", false);
        }
      }
    });
  });


  $btnSaveParticularPayments.on("click",function(){
    var input = $inputParticularPayments.val();
    var data = {
      id: _id,
      particular: input,
      authenticity_token: _authenticityToken
    }
    $inputParticularPayments.prop("disabled",true);

    $.ajax({
      url: "/api/v1/billing_for_involuntary/add_particular_to_loan_payments",
      data: data,
      method: "POST",
      success: function(response) {
        $message.html("Success! Redirecting...");
        window.location.reload();
      },
      error: function(response) {
        var errors  = [];
        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          errors  = ["Something went wrong"]
        } finally {
          alert(errors);
          $inputParticularPayments.prop("disabled", false);
        }
      }

    });

  });


  $btnSaveParticularTransfer.on("click", function() {
    var input = $inputParticularSavings.val();
    var data = {
      id: _id,
      particular: input,
      authenticity_token: _authenticityToken
    }

    $inputParticularSavings.prop("disabled", true);

    $.ajax({
      url: "/api/v1/billing_for_involuntary/add_particular_to_transfer_savings",
      data: data,
      method: "POST",
      success: function(response) {
        $message.html("Success! Redirecting...");
        window.location.reload();
      },
      error: function(response) {
        var errors  = [];
        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          errors  = ["Something went wrong"]
        } finally {
          alert(errors);
          $inputParticularSavings.prop("disabled", false);
        }
      }
    });
  });

  $btnAdd.on("click", function() {
    _memberId = $selectMember.val();
    var data = {
      id: _id,
	    member_id: _memberId,
	    authenticity_token: _authenticityToken
    };  
    $selectMember.prop("disabled", true);
 
    $.ajax({
	    url: "/api/v1/billing_for_involuntary/add_member",
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


var init  = function(options) {
  _authenticityToken = options.authenticityToken;
  _id                = options.id
  _cacheDom();
  _bindEvents();
}

export default { init: init };






