import Mustache from "mustache/mustache";

var $btnGenerateDailyReport;
var $btnConfirmGenerateDailyReport;
var $modalGenerateDailyReport;
var $selectBranch;
var $inputAsOf;
var $xFormControl;

var $message;
var templateErrorList;
var templateSuccessMessage;

var _urlGenerateDailyReport;
var _userId;
var _xKoinsAppAuthSecret;

var _cacheDom = function() {
  $btnGenerateDailyReport         = $("#btn-generate-daily-report");
  $btnConfirmGenerateDailyReport  = $("#btn-confirm-generate-daily-report");
  $modalGenerateDailyReport       = $("#modal-generate-daily-report");
  $selectBranch                   = $("#select-branch");
  $inputAsOf                      = $("#input-as-of");
  $xFormControl                   = $(".x-form-control");

  $message                = $(".message");
  templateErrorList       = $("#template-error-list").html();
  templateSuccessMessage  = $("#template-success-message").html();
};

var _bindEvents = function() {
  $btnGenerateDailyReport.on("click", function() {
    $modalGenerateDailyReport.modal("show");
  });

  $btnConfirmGenerateDailyReport.on("click", function() {
    var asOf      = $inputAsOf.val();
    var branchId  = $selectBranch.val();

    var data = {
      as_of: asOf,
      branch_id: branchId,
      user_id: _userId
    }

    $xFormControl.prop("disabled", true);
    $message.html("Loading...");

    $.ajax({
      url: _urlGenerateDailyReport,
      method: 'POST',
      headers: {
        'X-KOINS-APP-AUTH-SECRET': _xKoinsAppAuthSecret,
        'Access-Control-Allow-Methods': '*',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true'
      },
      data: data,
      success: function(response) {
        $message.html(
          Mustache.render(
            templateSuccessMessage,
            { message: "Success! You may now close this window" }
          )
        );


        $xFormControl.prop("disabled", false);
        $selectBranch.val("");
      },
      error: function(response) {
        console.log(response.responseText);
        var errors  = [];

        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          console.log(err);
          errors  = ["Something went wrong"];
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $xFormControl.prop("disabled", false);
        }
      }
    });
  });
};

var init = function(config) {
  _urlGenerateDailyReport = config.urlGenerateDailyReport;
  _userId                 = config.userId;
  _xKoinsAppAuthSecret    = config.xKoinsAppAuthSecret;

  _cacheDom();
  _bindEvents();
};

export default { init: init };
