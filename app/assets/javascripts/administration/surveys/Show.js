var Show  = (function() {
  var $btnDelete;
  var $btnConfirmDelete;
  var $modalDelete;
  var $message;

  var id;
  var authenticityToken;
  var templateErrorList;

  var urlDelete = "/api/v1/administration/surveys/delete";

  var _cacheDom = function() {
    $btnDelete        = $("#btn-delete");
    $btnConfirmDelete = $("#btn-confirm-delete");
    $modalDelete      = $("#modal-delete");
    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnDelete.on("click", function() {
      $modalDelete.modal("show");
      $message.html("");
    });

    $btnConfirmDelete.on("click", function() {
      $btnConfirmDelete.prop("disabled", true);

      $.ajax({
        url: urlDelete,
        method: 'POST',
        data: {
          authenticity_token: authenticityToken,
          id: id
        },
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href = "/administration/surveys";
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

  var init  = function(options) {
    id                  = options.id;
    authenticityToken = options.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  }
})();
