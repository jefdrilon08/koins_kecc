//= require signature_pad/dist/signature_pad

var Show  = (function() {
  var $modalGenerateAccessToken;
  var $modalSignature;
  var $btnGenerateAccessToken;
  var $btnGenerateSignature;
  var $btnClearSignature;
  var $btnConfirmGenerateAccessToken;
  var $btnConfirmSignature;
  var $message;

  var _urlGenerateAccessToken = "/api/v1/members/generate_access_token";
  var _urlSaveSignature       = "/api/v1/members/save_signature";
  var _memberId;
  var _authenticityToken;

  var _canvas;
  var _signaturePad;

  var _cacheDom = function() {
    _canvas       = document.querySelector("#signature-canvas");
    _signaturePad = new SignaturePad(_canvas);

    $modalGenerateAccessToken       = $("#modal-generate-access-token");
    $modalSignature                 = $("#modal-signature");
    $btnGenerateAccessToken         = $("#btn-generate-access-token");
    $btnConfirmGenerateAccessToken  = $("#btn-confirm-generate-access-token");
    $btnConfirmSignature            = $("#btn-confirm-signature");
    $btnGenerateSignature           = $("#btn-generate-signature");
    $btnClearSignature              = $("#btn-clear-signature");

    $message  = $(".message");
  }

  var _bindEvents = function() {
    $btnConfirmSignature.on("click", function() {
      $btnConfirmSignature.prop("disabled", true);

      if(_signaturePad.isEmpty()) {
        alert("No signature detected");
        $btnConfirmSignature.prop("disabled", false);
      } else {
        $.ajax({
          url: _urlSaveSignature,
          method: "POST",
          data: {
            signature_data: _signaturePad.toDataURL(),
            id: _memberId,
            authenticity_token: _authenticityToken
          },
          success: function(response) {
            $message.html("Success! Reloading...");
            window.location.reload();
          },
          error: function(response) {
            alert("Error in saving signature");
            $btnConfirmSignature.prop("disabled", false);
          }
        });
      }
    });

    $btnClearSignature.on("click", function() {
      _signaturePad.clear();
    });

    $btnGenerateSignature.on("click", function() {
      $modalSignature.modal("show");
    });

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
