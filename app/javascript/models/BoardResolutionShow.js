import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var _authenticityToken;
var _id;
var $btnApprove;
var $modalApproveBoardResolution;
var $btnConfirmProcess; 
var $printMessage;

var $message;
var templateErrorList;

var loader;

var _cacheDom = function() {
	
  $modalApproveBoardResolution = new bootstrap.Modal(
    document.getElementById("modal-approve-board-resolution")
  )

  $btnApprove             = $("#btn-approve");
  $btnConfirmProcess      = $("#btn-confirm-process");
  $message                = $(".message");
  $printMessage           = $(".print-message");
  templateErrorList       = $("#template-error-list").html();
  loader                  = $("#template-loader").html();
  
};

var _bindEvents = function() {

     $btnApprove.on("click", function() {
      _id = $(this).data("id");
      $modalApproveBoardResolution.show();
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
        url: "/api/v1/data_stores/board_resolution/approve",
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href = "/data_stores/board_resolution";
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

};


var init  = function(options) {
  _id                = options.id;
  _authenticityToken = options.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };