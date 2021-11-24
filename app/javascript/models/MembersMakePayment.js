
import Mustache from "mustache/mustache";

var authenticityToken;

var $modalNew;
var $btnNew;
var $btnConfirmNew;

var $selectYear;
var $selectBranch;

var $selectBook;
var  $inputPaticular
var  $inputOrNumber
var  $inputArNumber


var $message;
var templateErrorList;

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

  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
}

var _bindEvents = function() {
  $btnNew.on("click", function() {

    var data = {
      member_id:  $(this).data("member-id"),
      book:       $selectBook.val(),
      particular: $inputPaticular.val(),
      or_number:  $inputOrNumber.val(),
      ar_number:  $inputArNumber.val()
      
    }
    $.ajax({
      url: "/api/v1/members/save_make_payment",
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
