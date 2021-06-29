import Mustache from "mustache/mustache";

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
  $modalApprove         = $("#modal-approve");
  $selectMember         = $("#select-member");
  $inputAmount          = $("#input-amount");
  $inputParticular      = $("#input-particular");
  $message              = $(".message");
  templateErrorList     = $("#template-error-list").html();
};

var _bindEvents = function() {
  $btnApprove.on("click", function() {
    $modalApprove.modal("show");
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

    $btnAdd.prop("disabled", true);
    $inputAmount.prop("disabled", true);
    $selectMember.prop("disabled", true);

    var data  = {
      id: _id,
      authenticity_token: _authenticityToken,
      amount: amount,
      member_id: memberId
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
