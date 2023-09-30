import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var _authenticityToken;
var _id;

var $btnAddBook;
var $inputBookType;
var $modalViewDetails;
var $viewDetails;
var $$displayMember;

var currentMember           = "";
var currentMemberId         = "";

var $btnAdd;
var $btnApprove;
var $btnConfirmProcess; 
var $UpdateAmount;
var $modalUpdate;
var $modalApproveTransaction;
var $btnAddParticular;
var $inputParticular;
var _urlAddParticular   = "/api/v1/billing_for_involuntary/add_particular";
var _loanId;
var _memberId;


var $message;
var templateErrorList;

var _cacheDom = function() {

  $modalUpdate = new bootstrap.Modal(
    document.getElementById("modal-update-transaction")
  )

  $modalViewDetails = new bootstrap.Modal(
    document.getElementById("modal-view-details")
  )
	
  $modalApproveTransaction = new bootstrap.Modal(
    document.getElementById("modal-approve-transaction")
  )
  $btnAddBook             = $("#btn-add-book");
  $inputBookType          = $("#book_type");
  $viewDetails        = $("#btn-view-details");
  $btnAdd             = $("#btn-add");	
  $btnConfirmAmount   = $("#btn-confirm-amount")
  $btnApprove         = $("#btn-approve");
  $btnConfirmProcess  = $("#btn-confirm-process");
  $selectMember       = $("#select-member");
  $UpdateAmount       = $(".undo");
  $paymentAmount      = $("#paymentAmount");		
  $memberName         = $("#memberName");
  $memberId           = $("#memberId");
  $loanType           = $("#loanType");
  $btnAddParticular   = $("#btn-add-particular");
  $inputParticular    = $("#particular");
  $message            = $(".message");
};

var _bindEvents = function() {

  $viewDetails.on("click",function(){
    $message.html("");
    console.log($(this).data);
    currentMember           = $(this).data("member-name");
    currentMemberId         = $(this).data("member-id");
    _id = $(this).data("id");
    $displayMember.html(currentMember);
    $modalViewDetails.show();

    $.ajax({
      url: "/api/v1/billing_for_involuntary/view_details",
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

  $btnAddBook.on("click", function() {
    //alert("jayson");
     var txtBookType = $inputBookType.val()   
     _id = $(this).data("id");    
      $.ajax({      
        url: _urlAddBookType,
        method: "POST",
        data: {
    id: _id,
    txtBookType:  txtBookType,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          $message.html("Success!");
          window.location.reload();
        },
        error: function(response) {
          var errors  = [];

          try {
            errors  = JSON.parse(response.responseText).full_messages;
          } catch(err) {
            errors = ["Something went wrong"];
          } finally {
            $message.html(
              Mustache.render(
                templateErrorList,
                { errors: errors }
              )
            );

            $btnAddBook.prop("disabled", false);
          }
        }
      });
 
  });

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

  $UpdateAmount.on("click" , function() {
    console.log($(this));
	  $modalUpdate.show();
  });
   
  $btnConfirmAmount.on("click", function() {
    _paymentAmount	= $paymentAmount.val()	     
    _id 		        = $(this).data("id");	
    _memberId	      = $memberId.text()
  
    var data = {
		  id: _id,
		  member_name: $memberName.text(),
		  member_id: _memberId,   
		  loan_id: _loanId,   
		  payment_amount: _paymentAmount,
		  authenticity_token: _authenticityToken
	  };
    $.ajax({
      url: "/api/v1/billing_for_involuntary/update_amount",
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
    $modalApproveTransaction.show();
  });

  $btnConfirmProcess.on("click", function() {
    var data = {
      id: _id,
      authenticity_token: _authenticityToken
    };
    $btnConfirmProcess.prop("disabled", true);
    $message.html("Loading...");
    console.log(data);
    $.ajax({
      url: "/api/v1/billing_for_involuntary/approve",
      method: 'POST',
      data: data,
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

          $btnConfirmProcess.prop("disabled", false);
        }
      }
    });
  });
 
  $btnAddParticular.on("click", function() {
    var txtParticular = $inputParticular.val()
      _id = $(this).data("id");	  
      $.ajax({	    
        url: _urlAddParticular,
        method: "POST",
        data: {
          id: _id,
          txtParticular: txtParticular,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          $message.html("Success!");
          window.location.reload();
        },
        error: function(response) {
          var errors  = [];
          try {
            errors  = JSON.parse(response.responseText).full_messages;
          } catch(err) {
            errors = ["Something went wrong"];
          } finally {
            $message.html(
              Mustache.render(
                templateErrorList,
                { errors: errors }
              )
            );

            $btnAddParticular.prop("disabled", false);
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






