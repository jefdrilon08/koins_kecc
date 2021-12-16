import Mustache from "mustache/mustache";

var _authenticityToken;
var _id;

var $btnApprove;
var $btnConfirmApprove;
var $modalApprove;

var $btnDelete;
var $btnConfirmDelete;
var $modalDelete;

var $selectMember;
var $selectAccount;
var $selectAdjustment;
var $inputAmount;
var $btnAdd;


var $displayMember;
var $displayAccountSubtype;
var $displayPostType;
var $displayAccountingCode;
var $selectLoan;
var $message;

var templateErrorList;

var currentMember           = "";
var currentMemberAccountId  = "";
var currentAccountSubtype   = "";
var currentAccountingCodeId = "";
var currentPostType         = "";


var _cacheDom = function() {


  $btnApprove         = $("#btn-approve");
  $btnConfirmApprove  = $("#btn-confirm-approve");
  $modalApprove       = $("#modal-approve");
  $inputAmount        = $("#input-amount");


  $selectMember     = $("#select-member");
  $selectLoan       = $("#select-loan")
  $btnAdd           = $("#btn-add");

 


  $displayMember          = $(".display-member");

  $message  = $(".message");

  templateErrorList = $("#template-error-list").html();
};

var _bindEvents = function() {

  $btnAdd.on("click", function() {
    var memberId        = $selectMember.val();
    var loanProductId   = $selectLoan.val();
    var amount          = $inputAmount.val();

    var data  = {
      id: _id,
      member_id: memberId,
      loan_product_id: loanProductId,
      amount: amount,
      authenticity_token: _authenticityToken
    };

    $selectMember.prop("disabled", true);
    $selectLoan.prop("disabled", true);
    $inputAmount.prop("disabled", true);

    $.ajax({
      url: "/api/v1/billing_for_writeoff/add_member",
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
          $selectLoan.prop("disabled", false);
          $inputAmount.prop("disabled", false);
        }
      }
    });
  });

$btnApprove.on("click", function() {
    $message.html("");
    $modalApprove.modal("show");
  });


 $btnConfirmApprove.on("click", function() {
    var data = {
      id: _id,
      authenticity_token: _authenticityToken
    };
    $btnConfirmApprove.prop("disabled", true);
    $message.html("Loading...");
    
    console.log(data);
    $.ajax({
      url: "/api/v1/billing_for_writeoff/approve",
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Redirecting...");
        window.location.href="/billing_for_writeoff";
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

          $btnConfirmApprove.prop("disabled", false);
        }
      }
    });
  });
  
  
};

var init  = function(options) {
  _authenticityToken  = options.authenticityToken; 
  _id                 = options.id;

  _cacheDom();
  _bindEvents();
};

export default { init: init };
