import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var id;
var authenticityToken;
var $message;
var $inputEquityValue;
var $btnConfirmUpdateEquityValue;
var $modalUpdateEquityValue;
var templateErrorList;

var init = function(options) {
  id = options.id;
  authenticityToken = options.authenticityToken;
  $message = $(".message");
  $inputEquityValue = $("#input-equity-value");
  $btnConfirmUpdateEquityValue = $("#btn-confirm-update-equity-value");
  templateErrorList = $("#template-error-list").html();

  var modal = document.getElementById("modal-update-equity-value");
  if (!modal) return;

  $modalUpdateEquityValue = new bootstrap.Modal(modal);

  $("#btn-update-equity-value").on("click", function() {
    $message.html("");
    $modalUpdateEquityValue.show();
  });

  $btnConfirmUpdateEquityValue.on("click", function() {
    $btnConfirmUpdateEquityValue.prop("disabled", true);
    $inputEquityValue.prop("disabled", true);

    $.ajax({
      url: "/api/v1/equity_accounts/update_equity_value",
      method: "POST",
      data: {
        id: id,
        authenticity_token: authenticityToken,
        equity_value: $inputEquityValue.val()
      },
      success: function() {
        $message.html("Success! Redirecting...");
        window.location.reload();
      },
      error: function(response) {
        var errors;
        try {
          errors = JSON.parse(response.responseText).full_messages;
        } catch (error) {
          errors = ["Something went wrong"];
        }
        $message.html(Mustache.render(templateErrorList, { errors: errors }));
        $btnConfirmUpdateEquityValue.prop("disabled", false);
        $inputEquityValue.prop("disabled", false);
      }
    });
  });
};

export default { init: init };
