import Mustache from "mustache";
import $ from 'jquery';
import * as bootstrap from "bootstrap";

var $btnApprove;
var $btnConfirmApproved;
var $modalApprove;

var $btnDeclined;
var $btnDeclinedConfirm 
var $modalDeclined;
var $btnButton;

var $message;
var templateErrorList;

var _id;
var _options;
var _authenticityToken;

var _urlApprove = "/api/v1/api_receive_members/approve";

var _cacheDom = function() {

  $btnApprove               = $("#btn-approve");
  $btnDeclined              = $("#btn-declined");
  $btnConfirmApproved       = $("#btn-confirm-approved")
  $btnDeclinedConfirm       = $("#btn-confirm-declined");
  $btnButton                = $("#btn-button");
  $message                  = $(".message");

  $modalApprove = new bootstrap.Modal(
    document.getElementById("modal-approve")
  );

  $modalDeclined = new bootstrap.Modal(
    document.getElementById("modal-declined")
  );
  
};

var _bindEvents = function() {
  $btnApprove.on("click", function() {
    $modalApprove.show();
    $message.html("");
  });
  
  $btnDeclined.on("click", function() {
    $modalDeclined.show();
    $message.html("");
  });
  
  $btnDeclinedConfirm.on("click", function() {
    console.log("cliked!");
  });

    $btnDeclinedConfirm.on("click", function() {
    console.log("cliked!");
  });

  $(document).on("click", "#btn-confirm-approved", function() {
    // $btnConfirmApprove.prop("disabled", true);
    var $button = $(this);  // the button 
    $button.prop("disabled", true);  // to disable the declare button

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

          // $btnConfirmApprove.prop("disabled", false);
          $button.prop("disabled", true);
        }
      }
    });
  });
};

var init = function(options) {
  _options = options;
  _id = _options.id;
  _authenticityToken = _options.authenticityToken;

  _cacheDom();
  _bindEvents();
};

export default { init: init };
