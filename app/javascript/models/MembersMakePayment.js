
import Mustache from "mustache/mustache";

var authenticityToken;

var $modalNew;
var $btnNew;
var $btnConfirmNew;

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
  $modalNew         = $("#modal-new");
  $btnNew           = $("#btn-save");
  $btnConfirmNew    = $("#btn-confirm-new");
  $selectYear       = $("#select-year");
  $selectBranch     = $("#select-branch");


  $selectBook       = $("#book_type");
  $inputPaticular   = $("#particular");
  $inputOrNumber    = $("#or_number");
  $inputArNumber    = $("#ar_number");



  $btnApprove       = $("#btn-approve");
  $modalApprove       = $("#modal-approve");
  $btnConfirmApprove  = $("#btn-confirm-approve");
  $btnDestroy       = $("#btn-destroy");
  $modalDelete       = $("#modal-delete");
  $btnConfirmDelete  = $("#btn-confirm-delete");

  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
}

var _bindEvents = function() {
  
  $btnDestroy.on("click", function() {
    $message.html("");
    $modalDelete.modal("show");
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
    $modalApprove.modal("show");
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
  $btnNew.on("click", function() {
    var data = {
      member_id:  $(this).data("member-id"),
      book:       $selectBook.val(),
      particular: $inputPaticular.val(),
      or_number:  $inputOrNumber.val(),
      ar_number:  $inputArNumber.val(),
      make_payment_type: $(this).data("make-payment-type")
      
    }
    $.ajax({
      url: "/api/v1/members/save_make_payment",
      method: 'POST',
      data: data,
      success: function(response) {
        window.location.href="/adjustments/make_payments/" + response.id;
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

  $btnConfirmNew.on("click", function() {
    var year      = $selectYear.val();
    var branchId  = $selectBranch.val();

    $message.html("Loading...");
    $btnConfirmNew.prop("disabled", true);
    $selectYear.prop("disabled", true);
    $selectBranch.prop("disabled", true);

    var data  = {
      year: year,
      branch_id: branchId,
      authenticity_token: authenticityToken
    }

    $.ajax({
      url: "/api/v1/data_stores/members_in_good_standing/queue",
      method: 'POST',
      data: data,
      success: function(response) {
        window.location.href="/data_stores/members_in_good_standing";
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

        $btnConfirmNew.prop("disabled", false);
        $selectYear.prop("disabled", false);
        $selectBranch.prop("disabled", false);
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
