var Show  = (function() {
  var $modalGenerateAccessToken;
  var $btnGenerateAccessToken;
  var $btnConfirmGenerateAccessToken;
  var $message;

  var _urlGenerateAccessToken = "/api/v1/members/generate_access_token";
  var _memberId;
  var _authenticityToken;

  var _cacheDom = function() {
    $modalGenerateAccessToken       = $("#modal-generate-access-token");
    $btnGenerateAccessToken         = $("#btn-generate-access-token");
    $btnConfirmGenerateAccessToken  = $("#btn-confirm-generate-access-token");

    $message  = $(".message");
  }

  var _bindEvents = function() {
    $btnGenerateAccessToken.on("click", function() {
      $modalGenerateAccessToken.modal("show");
    });

    $btnConfirmGenerateAccessToken.on("click", function() {
      $message.html("Loading...");
      $btnConfirmGenerateAccessToken.prop("disabled", true);

      $.ajax({
        url: _urlGenerateAccessToken,
        method: 'POST',
        data: {
          id: _memberId,
          authenticity_token: _authenticityToken
        },
        dataType: 'json',
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.reload();
        },
        error: function(response) {
          $message.html("Error in generating access_token");
          $btnConfirmGenerateAccessToken.prop("disabled", false);
        }
      });
    });
  }

  var init  = function(memberId, authenticityToken) {
    _memberId           = memberId
    _authenticityToken  = authenticityToken
    _cacheDom();
    _bindEvents();
  }

  return {
    init: init
  };
})();
