var Show  = (function() {
  var $btnSyncMaintaningBalance;
  var $btnConfirmSyncMaintainingBalance;
  var $modalSyncMaintainingBalance;
  var $inputMaintainingBalance;

  var $btnRequestTimeDepositWithdrawal;
  var $btnConfirmRequestTimeDepositWithdrawal;
  var $modalRequestTimeDepositWithdrawal;

  var id;
  var templateErrorList;
  var authenticityToken;

  var $message;

  var init  = function(options) {
    id                = options.id;
    authenticityToken = options.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  var _cacheDom = function() {
    $btnSyncMaintaningBalance         = $("#btn-sync-maintaining-balance");
    $btnConfirmSyncMaintainingBalance = $("#btn-confirm-sync-maintaining-balance");
    $modalSyncMaintainingBalance      = $("#modal-sync-maintaining-balance");
    $inputMaintainingBalance          = $("#input-maintaining-balance");

    $btnRequestTimeDepositWithdrawal        = $("#btn-request-time-deposit-withdrawal");
    $btnConfirmRequestTimeDepositWithdrawal = $("#btn-confirm-request-time-deposit-withdrawal");
    $modalRequestTimeDepositWithdrawal      = $("#modal-request-time-deposit-withdrawal");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnRequestTimeDepositWithdrawal.on("click", function() {
      $message.html("");
      $modalRequestTimeDepositWithdrawal.modal("show");
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
      $modalSyncMaintainingBalance.modal("show");
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
  };

  return {
    init: init
  }
})();
