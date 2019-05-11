var Show  = (function() {
  var $message;

  var $btnDelete;
  var $btnConfirmDelete;
  var $modalDelete;

  var $btnApprove;
  var $btnConfirmApprove;
  var $modalApprove;

  var templateErrorList;
  var _urlDelete  = "/api/v1/loans/delete_adjustment";
  var _urlApprove = "/api/v1/loans/approve_adjustment";

  var _id;
  var _loanId;
  var _authenticityToken;

  var _cacheDom = function() {
    $message          = $(".message");

    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $modalApprove       = $("#modal-approve");

    $btnDelete        = $("#btn-delete");
    $btnConfirmDelete = $("#btn-confirm-delete");
    $modalDelete      = $("#modal-delete");

    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnApprove.on("click", function() {
      $message.html("");
      $modalApprove.modal("show");
    });

    $btnConfirmApprove.on("click", function() {
      $btnConfirmApprove.prop("disabled", true);

      $.ajax({
        url: _urlApprove,
        method: 'POST',
        dataType: 'json',
        data: {
          id: _id,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href="/loans/" + _loanId;
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
          id: _id,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href="/loans/" + _loanId;
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
  };

  var init  = function(config) {
    _id                 = config.id;
    _loanId             = config.loanId;
    _authenticityToken  = config.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
