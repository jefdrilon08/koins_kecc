var Show  = (function() {
  var $message;
  var $btnReage;
  var $btnConfirmReage;
  var $modalReage;

  var templateErrorList;

  var _urlReage = "/api/v1/loans/reage";

  var _loanId;

  var _cacheDom = function() {
    $message          = $(".message");
    $btnReage         = $("#btn-reage");
    $btnConfirmReage  = $("#btn-confirm-reage");
    $modalReage       = $("#modal-reage");

    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnReage.on("click", function() {
      $modalReage.modal("show");
    });

    $btnConfirmReage.on("click", function() {
      $btnConfirmReage.prop("disabled", true);

      $.ajax({
        url: _urlReage,
        method: 'POST',
        dataType: 'json',
        data: {
          id: _loanId
        },
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.reload();
        },
        error: function(response) {
          var errors  = [];
          try {
            errors  = JSON.parse(response.responseText).errors;
          } catch(err) {
            errors  = ["Something went wrong"];
            console.log(err);
          } finally {
            $message.html(
              Mustache.render(
                templateErrorList,
                { errors: errors }
              )
            );

            $btnConfirmReage.prop("disabled", false);
          }
        }
      });
    });
  };

  var init  = function(loanId) {
    _loanId = loanId;
    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
