var Show = (function() {
  var _authenticityToken;
  var _id;

  var $btnDelete;
  var $btnConfirmDelete;
  var $modalDelete;

  var $message;

  var templateErrorList;

  var _urlDelete  = "/api/v1/adjustments/subsidiary_adjustments/destroy";

  var _cacheDom = function() {
    $btnDelete         = $("#btn-delete");
    $btnConfirmDelete  = $("#btn-confirm-delete");
    $modalDelete       = $("#modal-delete");

    $message  = $(".message");

    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnDelete.on("click", function() {
      $modalDelete.modal("show");
      $message.html("");
    });
    
    $btnConfirmDelete.on("click", function() {
      $message.html("Loading...");

      $btnConfirmDelete.prop("disabled", true);

      $.ajax({
        url: _urlDelete,
        method: 'POST',
        data: {
          authenticity_token: _authenticityToken,
          id: _id
        },
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );

          window.location.href="/adjustments/subsidiary_adjustments/";
        },
        error: function(response) {
          var errors  = [];

          try {
            errors  = JSON.parse(response.responseText).full_messages;
          } catch(err) {
            errors  = ["Something went wrong"]
          } finally {
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
    _authenticityToken  = options.authenticityToken; 
    _id                 = options.id;

    _cacheDom();
    _bindEvents();
  };

  return  {
    init: init
  };
})();
