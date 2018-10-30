var Show  = (function() {
  var $btnApprove;
  var $btnConfirmApprove;
  var $btnPrint;
  var $modalApprove;
  var $modalPrint;
  var $message;
  var $printMessage;

  var templateErrorList;
  var loader;

  var _authenticityToken;

  var loanId;

  var _cacheDom = function() {
    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $btnPrint           = $("#btn-print");
    $modalApprove       = $("#modal-approve");
    $modalPrint         = $("#modal-print");
    $message            = $(".message");
    $printMessage       = $(".print-message");

    templateErrorList = $("#template-error-list").html();
    loader            = $("#template-loader").html();
  };

  var _bindEvents = function() {
    $btnPrint.on("click", function() {
      var accountingEntryId = $btnPrint.data('id');

      $modalPrint.modal("show");
      $printMessage.html(
        Mustache.render(
          loader,
          {}
        )
      );

      $.ajax({
        url: "/api/v1/print/generate_file",
        method: "POST",
        data: {
          type: "accounting_entry",
          id: accountingEntryId,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          $printMessage.html(
            "Success! Redirecting..."
          );

          $modalPrint.modal("hide");
          window.open("/print?filename=" + response.filename, '_blank');
        },
        error: function(response) {
          $printMessage.html("Error!");
        }
      });
    });

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
          id: loanId,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          window.location.reload();
        },
        error: function(response) {
          console.log(response);
          var errors  = [];

          try {
            errors  = JSON.parse(response.responseText).errors.full_messages;
          } catch(e) {
            errors  = ["Something went wrong"];
          }

          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $btnConfirmApprove.prop("disabled", false);
        }
      });
    });
  };

  var init  = function(config) {
    _authenticityToken  = config.authenticityToken;
    
    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
