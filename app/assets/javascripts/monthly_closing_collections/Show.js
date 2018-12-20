var Show  = (function() {
  var $btnUpdate;
  var $btnConfirmUpdate;
  var $modalUpdate;

  var id;
  var templateErrorList;
  var authenticityToken;

  var $message;

  var _cacheDom = function() {
    $btnUpdate        = $("#btn-update");
    $btnConfirmUpdate = $("#btn-confirm-update");
    $modalUpdate      = $("#modal-update");
    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnUpdate.on("click", function() {
      $message.html("");
      $modalUpdate.modal("show");
    });

    $btnConfirmUpdate.on("click", function() {
      $btnConfirmUpdate.prop("disabled", true);

      $.ajax({
        url: "/api/v1/monthly_closing_collections/update",
        method: 'POST',
        data: {
          id: id,
          authenticity_token: authenticityToken
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

            $btnConfirmUpdate.prop("disabled", true);
          }
        }
      });
    });
  };

  var init  = function(options) {
    id                = options.id;
    authenticityToken = options.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
