import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var authenticityToken;

var $selectYear;
var $selectBranch;

var $selectBook;
var  $inputPaticular;
var  $inputOrNumber;
var  $inputArNumber;

var  $btnApprove;
var  $modalApprove;
var  $btnConfirmApprove;

var  $btnDestroy;
var  $modalDelete;
var  $btnConfirmDelete;

var $message;
var templateErrorList;
var _id;


var _cacheDom = function() {
  $modalApprove = new bootstrap.Modal(
    document.getElementById("modal-approve")
  );

  $modalDelete = new bootstrap.Modal(
    document.getElementById("modal-delete")
  );

  $selectBook       = $("#book_type");
  $inputPaticular   = $("#particular");
  $inputOrNumber    = $("#or_number");
  $inputArNumber    = $("#ar_number");

  $btnApprove         = $("#btn-approve");
  $btnConfirmApprove  = $("#btn-confirm-approve");
  $btnDestroy         = $("#btn-destroy");
  $btnConfirmDelete   = $("#btn-confirm-delete");

  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
}

var _bindEvents = function() {
  
  $btnDestroy.on("click", function() {
    $message.html("");
    $modalDelete.show();
    _id = $(this).data("make-payment-id")
  });

  $btnConfirmDelete.on("click", function() {
    
    var data = {
      make_payment_id: _id
    }

    $.ajax({
      url: "/api/v1/adjustments/make_payments/destroy",
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success!");
        window.location.href="/adjustments/make_payments";
      },
      error: function(response) {
        errors = [];

        try {
          errors = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          console.log(response);
          errors.push("Something went wrong");
        }

        $message.html(
          Mustache.render(
            templateErrorList,
            { errors: errors }
          )
        );

      }
    });
  });


  $btnApprove.on("click", function() {
    $message.html("");
    $modalApprove.show();
    _id = $(this).data("make-payment-id")
    
  });

   $btnConfirmApprove.on("click", function() {
    
    var data = {
                  make_payment_id: _id

                }
    $.ajax({
      url: "/api/v1/adjustments/make_payments/approve",
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Redirecting");
        window.location.href="/adjustments/make_payments/";
      },
      error: function(response) {
        errors = [];

        try {
          errors = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          console.log(response);
          errors.push("Something went wrong");
        }

        $message.html(
          Mustache.render(
            templateErrorList,
            { errors: errors }
          )
        );
      }
    });
  });
}

var init  = function(config) {
  authenticityToken = config.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
