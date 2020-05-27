import Mustache from "mustache/mustache";

var Show  = (function() {
  var $message;

  var $btnNewAdjustment;
  var $btnConfirmNewAdjustment;
  var $modalNewAdjustment;
  var $inputPrincipal;
  var $inputMonthlyInterestRate;
  var $inputNumInstallments;
  var $selectTerm;

  var $btnApprove;
  var $btnConfirmApprove;
  var $modalApprove;

  var $btnReage;
  var $btnConfirmReage;
  var $modalReage;

  var $btnDelete;
  var $btnConfirmDelete;
  var $modalDelete;

  var $btnChangeBook;
  var $btnConfirmChangeBook;
  var $modalChangeBook;
  var $selectBook;

  var $btnFirstDateOfPayment;
  var $btnConfirmFirstDateOfPayment;
  var $modalFirstDateOfPayment;
  var $inputFirstDateOfPayment;

  var $btnDateReleased;
  var $btnConfirmDateReleased;
  var $modalDateReleased;
  var $inputDateReleased;

  var templateErrorList;

  var $oldDate;
  var $btnDelayAmort;
  var $btnConfirmDelayAmort;
  var $modalDelayAmort;
  var $inputDelayAmort;
  var $inputReason;

  var reason        = "";
  var newDate       = "";
  var curretAmortId = "";

  var _urlReage               = "/api/v1/loans/reage";
  var _urlDelete              = "/api/v1/loans/delete";
  var _urlFirstDateOfPayment  = "/api/v1/loans/update_first_date_of_payment";
  var _urlDateReleased        = "/api/v1/loans/update_date_released";
  var _urlApprove             = "/api/v1/loans/approve";
  var _urlChangeBook          = "/api/v1/loans/change_book";
  var _urlDelayAmort          = "/api/v1/loans/delay_amort";
  var _urlNewAdjustment       = "/api/v1/loans/new_adjustment";

  var _loanId;
  var _authenticityToken;

  var _cacheDom = function() {
    $message          = $(".message");

    $btnNewAdjustment         = $("#btn-new-adjustment");
    $btnConfirmNewAdjustment  = $("#btn-confirm-new-adjustment");
    $modalNewAdjustment       = $("#modal-new-adjustment");
    $inputPrincipal           = $("#input-principal");
    $inputMonthlyInterestRate = $("#input-monthly-interest-rate");
    $inputNumInstallments     = $("#input-num-installments");
    $selectTerm               = $("#select-term");

    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $modalApprove       = $("#modal-approve");

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

    $btnChangeBook        = $("#btn-change-book");
    $btnConfirmChangeBook = $("#btn-confirm-change-book");
    $modalChangeBook      = $("#modal-change-book");
    $selectBook           = $("#select-book");

    $btnDelayAmort        = $(".btn-delay-amort");
    $oldDate              = $(".old-date");
    $btnConfirmDelayAmort = $("#btn-confirm-delay-amort");
    $modalDelayAmort      = $("#modal-delay-amort");
    $inputDelayAmort      = $("#input-delay-amort");
    $inputReason          = $("#input-reason");


    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnNewAdjustment.on("click", function() {
      $modalNewAdjustment.modal("show");
    });

    $btnConfirmNewAdjustment.on("click", function() {
      var principal           = $inputPrincipal.val();
      var monthlyInterestRate = $inputMonthlyInterestRate.val();
      var numInstallments     = $inputNumInstallments.val();
      var term                = $selectTerm.val();

      var data = {
        p_principal: principal,
        p_monthly_interest_rate: monthlyInterestRate,
        p_num_installments: numInstallments,
        p_term: term,
        id: _loanId,
        authenticity_token: _authenticityToken
      }

      $inputPrincipal.prop("disabled", true);
      $inputMonthlyInterestRate.prop("disabled", true);
      $inputNumInstallments.prop("disabled", true);
      $selectTerm.prop("disabled", true);
      $btnConfirmNewAdjustment.prop("disabled", true);

      $message.html("Loading...");

      $.ajax({
        url: _urlNewAdjustment,
        method: 'POST',
        dataType: 'json',
        data: data,
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href = "/loans/" + _loanId + "/adjustment/" + response.id;
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

            $inputPrincipal.prop("disabled", false);
            $inputMonthlyInterestRate.prop("disabled", false);
            $inputNumInstallments.prop("disabled", false);
            $selectTerm.prop("disabled", false);
            $btnConfirmNewAdjustment.prop("disabled", false);
          }
        }
      });
    });

    $btnDelayAmort.on("click", function() {
      var oldDate   = $(this).data("old-date"); 
      curretAmortId = $(this).data("id");

      $oldDate.html(oldDate);

      $modalDelayAmort.modal("show");
    });

    $btnConfirmDelayAmort.on("click", function() {
      var newDate = $inputDelayAmort.val();
      var reason  = $inputReason.val();

      $inputDelayAmort.prop("disabled", true);
      $inputReason.prop("disabled", true);
      $btnConfirmDelayAmort.prop("disabled", true);
      $message.html("Loading...");

      $.ajax({
        url: _urlDelayAmort,
        method: 'POST',
        dataType: 'json',
        data: {
          id: curretAmortId,
          new_date: newDate,
          reason: reason,
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

            $inputDelayAmort.prop("disabled", false);
            $inputReason.prop("disabled", false);
            $btnConfirmDelayAmort.prop("disabled", false);
          }
        }
      });
    });

    $btnChangeBook.on("click", function() {
      $modalChangeBook.modal("show");
    });

    $btnConfirmChangeBook.on("click", function() {
      var book  = $selectBook.val();

      $btnConfirmChangeBook.prop("disabled", true);
      $selectBook.prop("disabled", true);
      $message.html("Loading...");

      $.ajax({
        url: _urlChangeBook,
        method: 'POST',
        dataType: 'json',
        data: {
          id: _loanId,
          book: book,
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

            $btnConfirmChangeBook.prop("disabled", false);
            $selectBook.prop("disabled", false);
          }
        }
      });
    });

    $btnApprove.on("click", function() {
      $message.html("");
      $modalApprove.modal("show");
    });

    $btnConfirmApprove.on("click", function() {
      $btnConfirmApprove.prop("disabled", true);
      $message.html("Loading...");

      $.ajax({
        url: _urlApprove,
        method: 'POST',
        dataType: 'json',
        data: {
          id: _loanId,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href="/loans/" + response.id;
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

            $btnConfirmApprove.prop("disabled", false);
          }
        }
      });
    });

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
      $message.html("");
      $modalDelete.modal("show");
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

window.LoansShow  = Show;
