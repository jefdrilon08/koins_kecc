var Show  = (function() {
  var $btnApprove;
  var $btnConfirmApprove;
  var $modalApprove;
  var $message;

  var templateErrorList;

  var _authenticityToken;

  var loanId;

  var _cacheDom = function() {
    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $modalApprove       = $("#modal-approve");
    $message            = $(".message");

    templateErrorList = $("#template-error-list").html();
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
