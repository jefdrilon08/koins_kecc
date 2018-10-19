var Show  = (function() {
  var $btnApprove;
  var $btnConfirmApprove;
  var $modalApprove;
  var $message;

  var loanId;

  var _cacheDom = function() {
    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $modalApprove       = $("#modal-approve");
    $message            = $(".message");
  };

  var _bindEvents = function() {
    $btnApprove.on("click", function() {
      loanId  = $(this).data("id");
      $modalApprove.modal("show");
    });

    $btnConfirmApprove.on("click", function() {
      $btnConfirmApprove.prop("disabled", true);

      $message.html("Loading...");

      $.ajax({
        url: "/api/v1/accounting_entries/approve",
        method: "POST",
        dataType: 'json',
        data: {
          id: loanId
        },
        success: function(response) {
          window.location.reload();
        },
        error: function(response) {
        }
      });
    });
  };

  var init  = function() {
    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
