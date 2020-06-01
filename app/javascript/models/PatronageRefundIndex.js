import Mustache from "mustache/mustache"; 

var authenticityToken;

var $modalNew;
var $btnNew;
var $btnConfirmNew;

var $selectBranch;
var $inputStartDate;
var $inputEndDate;
var $inputEquityRate;

var $message;
var templateErrorList;

var _cacheDom = function() {
  $modalNew      = $("#modal-new");
  $btnNew        = $("#btn-new");
  $btnConfirmNew = $("#btn-confirm-new");

  $selectBranch     = $("#select-branch");
  $inputStartDate   = $("#input-start-date");
  $inputEndDate     = $("#input-end-date");
  $inputEquityRate  = $("#input-equity-rate");

  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
}

var _bindEvents = function() {
  $btnNew.on("click", function() {
    $modalNew.modal("show");
    $message.html("");
  });

  $btnConfirmNew.on("click", function() {
    var branchId    = $selectBranch.val();
    var startDate   = $inputStartDate.val();
    var endDate     = $inputEndDate.val();
    var equityRate  = $inputEquityRate.val();

    $message.html("Loading...");
    $btnConfirmNew.prop("disabled", true);
    $selectBranch.prop("disabled", true);
    $inputStartDate.prop("disabled", true);
    $inputEndDate.prop("disabled", true);
    $inputEquityRate.prop("disabled", true);

    var data  = {
      start_date: startDate,
      end_date: endDate,
      equity_rate: equityRate,
      branch_id: branchId,
      authenticity_token: authenticityToken
    }

    $.ajax({
      url: "/api/v1/data_stores/patronage_refund/queue",
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Redirecting...");
        window.location.href="/data_stores/patronage_refund";
      },
      error: function(response) {
        $message.html("Something went wrong...");
        $btnConfirmNew.prop("disabled", false);
        $selectBranch.prop("disabled", false);

        $inputStartDate.prop("disabled", false);
        $inputEndDate.prop("disabled", false);
        $inputEquityRate.prop("disabled", false);
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
