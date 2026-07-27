import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var $btnSyncMaintaningBalance;
var $btnConfirmSyncMaintainingBalance;
var $modalSyncMaintainingBalance;
var $inputMaintainingBalance;
var $btnUpdateSemiMonthlyCollection;
var $btnConfirmUpdateSemiMonthlyCollection;
var $modalUpdateSemiMonthlyCollection;
var $inputSemiMonthlyCollection;
var $btnUpdateEquityValue;
var $btnConfirmUpdateEquityValue;
var $modalUpdateEquityValue;
var $inputEquityValue;

var $btnRequestTimeDepositWithdrawal;
var $btnConfirmRequestTimeDepositWithdrawal;
var $modalRequestTimeDepositWithdrawal;

var $btnDeleteWithdrawalRequest;
var $btnConfirmDeleteWithdrawalRequest;
var $modalDeleteWithdrawalRequest;

var $btnApproveWithdrawalRequest;
var $btnConfirmApproveWithdrawalRequest;
var $modalApproveWithdrawalRequest;

var $btnPrintWithdrawalRequest;
var $modalPrint;
var $btnPrintLedger;

var id;
var templateErrorList;
var authenticityToken;

var _currentWithdrawalRequestId;
var _PrintLedgerRequestId;
var SavingsAccountId; 
var $message;

var init  = function(options) {
  console.log(options)
  id                = options.id;
  authenticityToken = options.authenticityToken;
  SavingsAccountId  = options.id;
  _cacheDom();
  _bindEvents();
};

var _cacheDom = function() {
  $btnDeleteWithdrawalRequest         = $(".btn-delete-withdrawal-request");
  $btnConfirmDeleteWithdrawalRequest  = $("#btn-confirm-delete-withdrawal-request");
  $modalDeleteWithdrawalRequest       = $("#modal-delete-withdrawal-request");

  $btnApproveWithdrawalRequest        = $(".btn-approve-withdrawal-request");
  $btnConfirmApproveWithdrawalRequest = $("#btn-confirm-approve-withdrawal-request");

  $modalApproveWithdrawalRequest = new bootstrap.Modal(
    document.getElementById("modal-approve-withdrawal-request")
  )




  $btnSyncMaintaningBalance         = $("#btn-sync-maintaining-balance");
  $btnConfirmSyncMaintainingBalance = $("#btn-confirm-sync-maintaining-balance");

  $modalSyncMaintainingBalance = new bootstrap.Modal(
    document.getElementById("modal-sync-maintaining-balance")
  )

  $btnUpdateSemiMonthlyCollection = $("#btn-update-semi-monthly-collection");
  $btnConfirmUpdateSemiMonthlyCollection = $("#btn-confirm-update-semi-monthly-collection");
  $modalUpdateSemiMonthlyCollection = new bootstrap.Modal(
    document.getElementById("modal-update-semi-monthly-collection")
  )

  $btnUpdateEquityValue = $("#btn-update-equity-value");
  $btnConfirmUpdateEquityValue = $("#btn-confirm-update-equity-value");
  $modalUpdateEquityValue = new bootstrap.Modal(
    document.getElementById("modal-update-equity-value")
  )

  $inputMaintainingBalance          = $("#input-maintaining-balance");
  $inputSemiMonthlyCollection       = $("#input-semi-monthly-collection");
  $inputEquityValue                 = $("#input-equity-value");

  $btnRequestTimeDepositWithdrawal        = $("#btn-request-time-deposit-withdrawal");
  $btnConfirmRequestTimeDepositWithdrawal = $("#btn-confirm-request-time-deposit-withdrawal");
  $modalRequestTimeDepositWithdrawal = new bootstrap.Modal(
    document.getElementById("modal-request-time-deposit-withdrawal")
  )

  $btnPrintWithdrawalRequest  = $(".btn-print-withdrawal-request");
  $modalPrint = new bootstrap.Modal(
    document.getElementById("modal-print")
  )
  
  $btnPrintLedger             = $("#btn-print-ledger");

  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
};

var _bindEvents = function() {
  $btnPrintLedger.on("click", function() {
    $modalPrint.show();
    
    var type = "print_ledger";
    
    $modalPrint.hide();
    window.open("/print?type=" + type + "&id=" + id);
  });

  $btnPrintWithdrawalRequest.on("click", function() {
    _currentWithdrawalRequestId = $(this).data("id");
    $message.html("");

    $modalPrint.show();

    $.ajax({
      url: "/api/v1/print/generate_file",
      method: "POST",
      data: {
        id: _currentWithdrawalRequestId,
        type: "withdrawal_request",
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );

        $modalPrint.hide();
        window.open("/print?filename=" + response.filename, '_blank');
      },
      error: function(response) {
        $message.html("Error in printing withdrawal request!");
      }
    });
  });

  $btnApproveWithdrawalRequest.on("click", function() {
    _currentWithdrawalRequestId = $(this).data("id");
    $message.html("");

    $modalApproveWithdrawalRequest.show();
  });

  $btnConfirmApproveWithdrawalRequest.on("click", function() {
    $btnConfirmApproveWithdrawalRequest.prop("disabled", true);
    $message.html("Loading...");

    $.ajax({
      url: "/api/v1/savings_accounts/approve_withdrawal_request",
      method: 'POST',
      data: {
        id: id,
        data_store_id: _currentWithdrawalRequestId,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html("Success! Redirecting...");
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

          $btnConfirmApproveWithdrawalRequest.prop("disabled", false);
        }
      }
    });
  });

  $btnDeleteWithdrawalRequest.on("click", function() {
    _currentWithdrawalRequestId = $(this).data("id");
    $message.html("");

    $modalDeleteWithdrawalRequest.show();
  });

  $btnConfirmDeleteWithdrawalRequest.on("click", function() {
    $btnConfirmDeleteWithdrawalRequest.prop("disabled", true);
    $message.html("Loading...");

    $.ajax({
      url: "/api/v1/savings_accounts/delete_withdrawal_request",
      method: 'POST',
      data: {
        id: id,
        data_store_id: _currentWithdrawalRequestId,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html("Success! Redirecting...");
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

          $btnConfirmDeleteWithdrawalRequest.prop("disabled", false);
        }
      }
    });
  });

  $btnRequestTimeDepositWithdrawal.on("click", function() {
    $message.html("");
    $modalRequestTimeDepositWithdrawal.show();
  });

  $btnConfirmRequestTimeDepositWithdrawal.on("click", function() {
    $btnConfirmRequestTimeDepositWithdrawal.prop("disabled", true);
    $message.html("Loading...");

    $.ajax({
      url: "/api/v1/savings_accounts/request_time_deposit_withdrawal",
      method: 'POST',
      data: {
        id: id,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html("Success! Redirecting...");
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

          $btnConfirmRequestTimeDepositWithdrawal.prop("disabled", false);
        }
      }
    });
  });

  $btnSyncMaintaningBalance.on("click", function() {
    $message.html("");
    $modalSyncMaintainingBalance.show();
  });

  $btnConfirmSyncMaintainingBalance.on("click", function() {
    var maintainingBalance  = $inputMaintainingBalance.val();

    $btnConfirmSyncMaintainingBalance.prop("disabled", true);
    $inputMaintainingBalance.prop("disabled", true);

    $.ajax({
      url: "/api/v1/savings_accounts/sync_maintaining_balance",
      method: 'POST',
      data: {
        id: id,
        authenticity_token: authenticityToken,
        maintaining_balance: maintainingBalance
      },
      success: function(response) {
        $message.html("Success! Redirecting...");
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

          $btnConfirmSyncMaintainingBalance.prop("disabled", false);
          $inputMaintainingBalance.prop("disabled", false);
        }
      }
    });
  });

  $btnUpdateSemiMonthlyCollection.on("click", function() {
    $message.html("");
    $modalUpdateSemiMonthlyCollection.show();
  });

  $btnConfirmUpdateSemiMonthlyCollection.on("click", function() {
    var semiMonthlyCollection = $inputSemiMonthlyCollection.val();

    $btnConfirmUpdateSemiMonthlyCollection.prop("disabled", true);
    $inputSemiMonthlyCollection.prop("disabled", true);

    $.ajax({
      url: "/api/v1/savings_accounts/update_semi_monthly_collection",
      method: 'POST',
      data: {
        id: id,
        authenticity_token: authenticityToken,
        semi_monthly_collection: semiMonthlyCollection
      },
      success: function(response) {
        $message.html("Success! Redirecting...");
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

          $btnConfirmUpdateSemiMonthlyCollection.prop("disabled", false);
          $inputSemiMonthlyCollection.prop("disabled", false);
        }
      }
    });
  });

  $btnUpdateEquityValue.on("click", function() {
    $message.html("");
    $modalUpdateEquityValue.show();
  });

  $btnConfirmUpdateEquityValue.on("click", function() {
    var equityValue = $inputEquityValue.val();

    $btnConfirmUpdateEquityValue.prop("disabled", true);
    $inputEquityValue.prop("disabled", true);

    $.ajax({
      url: "/api/v1/savings_accounts/update_equity_value",
      method: 'POST',
      data: {
        id: id,
        authenticity_token: authenticityToken,
        equity_value: equityValue
      },
      success: function(response) {
        $message.html("Success! Redirecting...");
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

          $btnConfirmUpdateEquityValue.prop("disabled", false);
          $inputEquityValue.prop("disabled", false);
        }
      }
    });
  });

};

export default { init: init }
