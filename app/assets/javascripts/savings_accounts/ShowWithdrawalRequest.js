var ShowWithdrawalRequest  = (function() {
  var $btnPrintWithdrawalRequest;
  var $modalPrint;

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
    $btnPrintWithdrawalRequest  = $("#btn-print-withdrawal-request");
    $modalPrint                 = $("#modal-print");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnPrintWithdrawalRequest.on("click", function() {
      $message.html("");

      $modalPrint.modal("show");

      $.ajax({
        url: "/api/v1/print/generate_file",
        method: "POST",
        data: {
          id: id,
          type: "withdrawal_request",
          authenticity_token: authenticityToken
        },
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );

          $modalPrint.modal("hide");
          window.open("/print?filename=" + response.filename, '_blank');
        },
        error: function(response) {
          $message.html("Error in printing withdrawal request!");
        }
      });
    });
  };

  return {
    init: init
  }
})();
