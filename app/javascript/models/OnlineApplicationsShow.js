import Mustache from "mustache/mustache";

var _id;
var _authenticityToken;

var $modalProcess;
var $modalReject;
var $modalVerify;
var $btnVerify;
var $btnConfirmVerify;
var $btnProcess;
var $btnConfirmProcess;
var $btnReject;
var $btnConfirmReject;
var $message;
var templateErrorList;
var templateCenterOptions;
var $selectBranch;
var $selectVerifyBranch;
var $selectCenter;
var $inputReason;
var _centers = [];

var _cacheDom = function() {
  $modalProcess         = $("#modal-process");
  $modalReject          = $("#modal-reject");
  $modalVerify          = $("#modal-verify");
  $btnProcess           = $("#btn-process");
  $btnConfirmProcess    = $("#btn-confirm-process");
  $btnReject            = $("#btn-reject");
  $btnConfirmReject     = $("#btn-confirm-reject");
  $btnVerify            = $("#btn-verify");
  $btnConfirmVerify     = $("#btn-confirm-verify");
  $inputReason          = $("#input-reason");
  $selectBranch         = $("#select-branch");
  $selectVerifyBranch   = $("#select-verify-branch");
  $selectCenter         = $("#select-center");
  $message              = $(".message");
  templateErrorList     = $("#template-error-list").html();
  templateCenterOptions = $("#template-center-options").html();
}

var _bindEvents = function() {
  $btnVerify.on("click", function() {
    $modalVerify.modal("show");
  });

  $btnConfirmVerify.on("click", function() {
    var branchId  = $selectVerifyBranch.val();

    $btnConfirmVerify.prop("disabled", true); 
    $selectVerifyBranch.prop("disabled", true);

    $.ajax({
      url: "/api/v1/online_applications/verify",
      method: "POST",
      data: {
        id: _id,
        branch_id: branchId,
        authenticity_token: _authenticityToken
      },
      success: function(response) {
        $message.html("Success! Reloading..."); 
        window.location.reload();
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

          $btnConfirmVerify.prop("disabled", false);
        }
      }
    });
  });

  if($selectBranch.val()) {
    $.ajax({
      url: "/api/v1/branches/fetch_centers",
      data: {
        id: $selectBranch.val()
      },
      success: function(response) {
        $selectCenter.html(
          Mustache.render(
            templateCenterOptions,
            response
          )
        )
      },
      error: function(response) {
        alert("Cannot fetch centers");
      }
    });
  }

  $btnReject.on("click", function() {
    $modalReject.modal("show");
  });

  $btnConfirmReject.on("click", function() {
    var reason  = $inputReason.val();

    $btnConfirmReject.prop("disabled", true);
    $inputReason.prop("disabled", true);

    $message.html("");

    $.ajax({
      url: "/api/v1/online_applications/reject",
      method: 'POST',
      data: {
        id: _id,
        reason: reason
      },
      success: function(response) {
        $message.html("Success! Reloading..."); 
        window.location.reload();
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

          $inputReason.prop("disabled", false);
          $btnConfirmReject.prop("disabled", false);
        }
      }
    });
  });

  $btnConfirmProcess.on("click", function() {
    var branchId  = $selectBranch.val();
    var centerId  = $selectCenter.val();

    $message.html("");

    $selectBranch.prop("disabled", true);
    $selectCenter.prop("disabled", true);
    $btnConfirmProcess.prop("disabled", true);

    $.ajax({
      url: "/api/v1/online_applications/process",
      method: 'POST',
      data: {
        id: _id,
        branch_id: branchId,
        center_id: centerId
      },
      success: function(response) {
        $message.html("Success! Redirecting..."); 
        window.location.href = "/members/" + response.member_id + "/display";
      },
      error: function(response) {
        console.log(response);
        var errors  = [];
        try {
          errors  = JSON.parse(response.responseText).errors;
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

          $selectBranch.prop("disabled", false);
          $selectCenter.prop("disabled", false);
          $btnConfirmProcess.prop("disabled", false);
        }
      }
    });
  });

  $btnProcess.on("click", function() {
    $modalProcess.modal("show");
  });

  $selectBranch.on("change", function() {
    var branchId = $(this).val();

    if(branchId) {
      $.ajax({
        url: "/api/v1/branches/fetch_centers",
        data: {
          id: branchId
        },
        success: function(response) {
          $selectCenter.html(
            Mustache.render(
              templateCenterOptions,
              response
            )
          )
        },
        error: function(response) {
          alert("Cannot fetch centers");
        }
      });
    }
  });
}

var init = function(options) {
  _id                 = options.id;
  _authenticityToken  = options.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
