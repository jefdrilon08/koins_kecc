import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";


var $btnAdd;
var $btnDelete;
var $btnApprove;
var $btnConfirmApprove;
var $modalApprove;
var $selectMember;
var $inputAmount;
var $inputParticular;
var $btnUpdateParticular;
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

var _urlAdd               = "/api/v1/savings_insurance_transfer_collections/add_member";
var _urlDelete            = "/api/v1/savings_insurance_transfer_collections/remove_member";
var _urlApprove           = "/api/v1/savings_insurance_transfer_collections/approve";
var _urlUpdateParticular  = "/api/v1/savings_insurance_transfer_collections/update_particular";

var _cacheDom = function() {
  $btnAdd               = $("#btn-add");
  $btnUpdateParticular  = $("#btn-update-particular");
  $btnDelete            = $(".btn-delete");
  $btnApprove           = $("#btn-approve");
  $btnConfirmApprove    = $("#btn-confirm-approve");
  $modalApprove         = new bootstrap.Modal( 
    document.getElementById("modal-approve")
  );
  $selectMember         = $("#select-member");
  $inputAmount          = $("#input-amount");
  $inputParticular      = $("#input-particular");
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

  $btnUpdateParticular.on("click", function() {
    var particular = $inputParticular.val();

    $btnUpdateParticular.prop("disabled", true);
    $inputParticular.prop("disabled", true);
    
    var data  = {
      id: _id,
      authenticity_token: _authenticityToken,
      particular: particular
    };

    $message.html("Loading...");

    $.ajax({
      url: _urlUpdateParticular,
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

          $btnUpdateParticular.prop("disabled", false);
          $inputParticular.prop("disabled", false);
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
