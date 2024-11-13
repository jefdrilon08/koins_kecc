import Mustache from "mustache";
import $ from 'jquery';
import * as bootstrap from "bootstrap";

var $btnAdd;
var $btnDelete;
var $btnApprove;
var $btnConfirmApprove;
var $modalApprove;
var $btnCheck;
var $btnConfirmCheck;
var $modalCheck;
var $btnPending;
var $btnConfirmPending;
var $modalPending;
var $selectMember;
var $message;
var templateErrorList;

var $inputLoanProductId;
var $inputPrincipal;
var $inputTerm;
var $inputNumInstallments;
var $inputMaturityDate;
var $inputEffectiveDate;
var $inputClipNumber;
var $inputBeneficiary;

var _id;
var _options;
var _authenticityToken;

var _urlAdd                = "/api/v1/kpf_loan_clips/add_member/";
var _urlDelete             = "/api/v1/kpf_loan_clips/remove_member";
var _urlApprove            = "/api/v1/kpf_loan_clips/approve";
var _urlCheckTransaction   = "/api/v1/kpf_loan_clips/check";

var _cacheDom = function() {

  $btnAdd               = $("#btn-add");
  $btnDelete            = $(".btn-delete");
  $btnApprove           = $("#btn-approve");
  $btnConfirmApprove    = $("#btn-confirm-approve");
  $btnCheck             = $("#btn-check");
  $btnConfirmCheck      = $("#btn-confirm-check");
  $btnPending           = $("#btn-pending");
  $btnConfirmPending    = $("#btn-confirm-pending");

  $modalApprove = new bootstrap.Modal(
    document.getElementById("modal-approve")
  );

  $modalCheck = new bootstrap.Modal(
    document.getElementById("modal-check-confirmation")
  );

  
  $selectMember         = $("#select-member");
  $inputAmount          = $("#input-amount");
  $message              = $(".message");
  templateErrorList     = $("#template-error-list").html();
  $inputLoanProductId   = $("#input-loan-product-id");
  $inputPrincipal       = $("#input-principal");
  $inputTerm            = $("#input-term");
  $inputNumInstallments = $("#input-num-installments");
  $inputMaturityDate    = $("#input-maturity-date");
  $inputEffectiveDate   = $("#input-effective-date");
  $inputClipNumber      = $("#input-clip-number");
  $inputBeneficiary     = $("#input-beneficiary");

};

var _bindEvents = function() {

  // check
  $btnCheck.on("click", function() {
    $modalCheck.show();
    $message.html("");
  });

  // approved
  $btnApprove.on("click", function() {
    $modalApprove.show();
    $message.html("");
  });

  $btnConfirmApprove.on("click", function() {
    $btnConfirmApprove.prop("disabled", true);

    var data  = {
      id: _id,
      authenticity_token: _authenticityToken
    };

    $message.html("Loading...");

    $.ajax({
      url: _urlApprove,
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Reloading...");
        window.location.reload();
      },
      error: function(response) {
        var errors = [];

        try {
          errors = JSON.parse(response.responseText).errors.full_messages;
        } catch(err) {
          errors.push("Something went wrong.");
        } finally {
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

  //delete
  $btnDelete.on("click", function() {
    var $btn      = $(this);
    var memberId  = $btn.data("member-id");

    $btn.prop("disabled", true);

    var data  = {
      id: _id,
      authenticity_token: _authenticityToken,
      member_id: memberId
    };

    $message.html("Loading...");

    $.ajax({
      url: _urlDelete,
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Reloading...");
        window.location.reload();
      },
      error: function(response) {
        var errors = [];

        try {
          errors = JSON.parse(response.responseText).errors.full_messages;
        } catch(err) {
          errors.push("Something went wrong.");
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $btn.prop("disabled", false);
        }
      }
    });
  });

  //Check
  $btnConfirmCheck.on("click", function() {
    $btnConfirmCheck.prop("disabled", true);

    var data  = {
      id: _id,
      authenticity_token: _authenticityToken
    };

    $message.html("Loading...");

    $.ajax({
      url: _urlCheckTransaction,
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Reloading...");
        window.location.reload();
      },
      error: function(response) {
        var errors = [];

        try {
          errors = JSON.parse(response.responseText).errors.full_messages;
        } catch(err) {
          errors.push("Something went wrong.");
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $btnConfirmCheck.prop("disabled", false);
        }
      }
    });
  });
 
  //Add
  $btnAdd.on("click", function() {
    var amount    = $inputAmount.val();
    var memberId  = $selectMember.val();

    var loanProductId        = $inputLoanProductId.val();
    var principal            = $inputPrincipal.val();
    var term                 = $inputTerm.val();
    var numInstallments      = $inputNumInstallments.val();
    var maturityDate         = $inputMaturityDate.val();
    var effectiveDate        = $inputEffectiveDate.val();
    var clipNumber           = $inputClipNumber.val();
    var beneficiary          = $inputBeneficiary.val();
  
    $btnAdd.prop("disabled", true);
    $inputAmount.prop("disabled", true);
    $selectMember.prop("disabled", true);
    $inputLoanProductId.prop("disabled", true);
    $inputPrincipal.prop("disabled", true);
    $inputTerm.prop("disabled", true);
    $inputNumInstallments.prop("disabled", true);
    $inputMaturityDate.prop("disabled", true);
    $inputEffectiveDate.prop("disabled", true);
    $inputClipNumber.prop("disabled", true);
    $inputBeneficiary.prop("disabled", true);

    var data  = {
      id: _id,
      authenticity_token: _authenticityToken,
      amount: amount,
      member_id: memberId,
      loan_product_id: loanProductId,
      principal: principal,
      term: term,
      num_installments: numInstallments,
      maturity_date: maturityDate,
      effective_date: effectiveDate,
      clip_number: clipNumber,
      beneficiary: beneficiary
    };

    $message.html("Loading...");
    $.ajax({
      url: _urlAdd,
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Reloading...");
        window.location.reload();
      },
      error: function(response) {
        var errors = [];

        try {
          errors = JSON.parse(response.responseText).errors.full_messages;
        } catch(err) {
          errors.push("Something went wrong.");
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $btnAdd.prop("disabled", false);
          $inputAmount.prop("disabled", false);
          $selectMember.prop("disabled", false);
          $inputLoanProductId.prop("disabled", false);
          $inputPrincipal.prop("disabled", false);
          $inputTerm.prop("disabled", false);
          $inputNumInstallments.prop("disabled", false);
          $inputMaturityDate.prop("disabled", false);
          $inputEffectiveDate.prop("disabled", false);
          $inputClipNumber.prop("disabled", false);
          $inputBeneficiary.prop("disabled", false);

        }
      }
    });
  });
};

var init  = function(options) {
  _options            = options;
  _id                 = _options.id
  _authenticityToken  = _options.authenticityToken;

  _cacheDom();
  _bindEvents();
};

export default { init: init };