import Mustache from "mustache/mustache";

var $modalDelete;
var $btnDelete;
var $btnConfirmDelete;
var $message;
var templateErrorList;
var _authenticityToken;

var _urlDelete  = "/api/v1/trial_balances/delete";
var _id;

var init  = function(options) {
  _authenticityToken  = options.authenticityToken;
  _id                 = options.id;

  _cacheDom();
  _bindEvents();
}

var _cacheDom = function() {
  $modalDelete      = $("#modal-delete");
  $btnDelete        = $("#btn-delete");
  $btnConfirmDelete = $("#btn-confirm-delete");
  $message          = $(".message");

  templateErrorList = $("#template-error-list").html();
};

var _bindEvents = function() {
  $btnDelete.on("click", function() {
    $modalDelete.modal("show");
  });

  $btnConfirmDelete.on("click", function() {
    $btnConfirmDelete.prop("disabled", true);

    $.ajax({
      url: _urlDelete,
      method: "POST",
      data: {
        id: _id,
        authenticity_token: _authenticityToken
      },
      success: function(response) {
        $message.html("Success!");
        window.location.href = "/accounting/trial_balances";
      },
      error: function(response) {
        var errors  = [];

        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          errors = ["Something went wrong"];
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $btnConfirmDelete.prop("disabled", false);
        }
      }
    });
  });
};

export default { init: init };
