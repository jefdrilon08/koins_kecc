var Show  = (function() {
  var $message;
  var $btnReage;
  var $btnConfirmReage;
  var $modalReage;

  var templateErrorList;

  var _urlReage = "/api/v1/loans/reage";

  var _loanId;
  var _authenticityToken;

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
          id: _loanId,
          authenticity_token: _authenticityToken
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

            $btnConfirmReage.prop("disabled", false);
          }
        }
      });
    });
  };

  var init  = function(config) {
    _loanId             = config.loanId;
    _authenticityToken  = config.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
