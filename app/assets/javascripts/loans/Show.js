var Show  = (function() {
  var $message;

  var $btnReage;
  var $btnConfirmReage;
  var $modalReage;

  var $btnDelete;
  var $btnConfirmDelete;
  var $modalDelete;

  var $btnFirstDateOfPayment;
  var $btnConfirmFirstDateOfPayment;
  var $modalFirstDateOfPayment;
  var $inputFirstDateOfPayment;

  var $btnDateReleased;
  var $btnConfirmDateReleased;
  var $modalDateReleased;
  var $inputDateReleased;

  var templateErrorList;

  var _urlReage               = "/api/v1/loans/reage";
  var _urlDelete              = "/api/v1/loans/delete";
  var _urlFirstDateOfPayment  = "/api/v1/loans/update_first_date_of_payment";
  var _urlDateReleased        = "/api/v1/loans/update_date_released";

  var _loanId;
  var _authenticityToken;

  var _cacheDom = function() {
    $message          = $(".message");

    $btnReage         = $("#btn-reage");
    $btnConfirmReage  = $("#btn-confirm-reage");
    $modalReage       = $("#modal-reage");

    $btnDelete        = $("#btn-delete");
    $btnConfirmDelete = $("#btn-confirm-delete");
    $modalDelete      = $("#modal-delete");

    $btnFirstDateOfPayment        = $("#btn-first-date-of-payment");
    $btnConfirmFirstDateOfPayment = $("#btn-confirm-first-date-of-payment");
    $modalFirstDateOfPayment      = $("#modal-first-date-of-payment");
    $inputFirstDateOfPayment      = $("#input-first-date-of-payment");

    $btnDateReleased        = $("#btn-date-released");
    $btnConfirmDateReleased = $("#btn-confirm-date-released");
    $modalDateReleased      = $("#modal-date-released");
    $inputDateReleased      = $("#input-date-released");

    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnDateReleased.on("click", function() {
      $message.html("");
      $modalDateReleased.modal("show");
    });

    $btnConfirmDateReleased.on("click", function() {
      var dateReleased  = $inputDateReleased.val();

      $btnConfirmDateReleased.prop("disabled", true);
      $inputDateReleased.prop("disabled", true);

      $.ajax({
        url: _urlDateReleased,
        method: 'POST',
        dataType: 'json',
        data: {
          id: _loanId,
          date_released: dateReleased,
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

            $btnConfirmDateReleased.prop("disabled", false);
            $inputDateReleased.prop("disabled", false);
          }
        }
      });
    });

    $btnFirstDateOfPayment.on("click", function() {
      $message.html("");
      $modalFirstDateOfPayment.modal("show");
    });

    $btnConfirmFirstDateOfPayment.on("click", function() {
      var firstDateOfPayment  = $inputFirstDateOfPayment.val();

      $btnConfirmFirstDateOfPayment.prop("disabled", true);
      $inputFirstDateOfPayment.prop("disabled", true);

      $.ajax({
        url: _urlFirstDateOfPayment,
        method: 'POST',
        dataType: 'json',
        data: {
          id: _loanId,
          first_date_of_payment: firstDateOfPayment,
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

            $btnConfirmFirstDateOfPayment.prop("disabled", false);
            $inputFirstDateOfPayment.prop("disabled", false);
          }
        }
      });

    });

    $btnDelete.on("click", function() {
      $modalDelete.modal("show");
      $message.html("");
    });

    $btnConfirmDelete.on("click", function() {
      $btnConfirmDelete.prop("disabled", true);

      $.ajax({
        url: _urlDelete,
        method: 'POST',
        dataType: 'json',
        data: {
          id: _loanId,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href="/members/" + response.id + "/display";
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

            $btnConfirmDelete.prop("disabled", false);
          }
        }
      });
    });

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
