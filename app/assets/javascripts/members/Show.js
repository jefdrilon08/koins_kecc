var Show  = (function() {
  var $modalGenerateAccessToken;
  var $modalSignature;
  var $modalNewLoan;
  var $modalDelete;
  var $modalCreateSurvey;
  var $modalRestore;
  var $modalUnlock;
  var $btnGenerateAccessToken;
  var $btnGenerateSignature;
  var $btnClearSignature;
  var $btnConfirmGenerateAccessToken;
  var $btnConfirmSignature;
  var $btnNewLoan;
  var $btnConfirmNewLoan;
  var $btnCreateSurvey;
  var $btnConfirmCreateSurvey;
  var $btnDelete;
  var $btnConfirmDelete;
  var $btnUnlock;
  var $btnConfirmUnlock;
  var $btnRestore;
  var $btnConfirmRestore;
  var $btnGenerateMissingAccounts;
  var $selectLoanProduct;
  var $selectSurvey;
  var $message;

  var templateErrorList;

  var _urlGenerateAccessToken     = "/api/v1/members/generate_access_token";
  var _urlSaveSignature           = "/api/v1/members/save_signature";
  var _urlNewLoan                 = "/api/v1/loans/apply";
  var _urlCreateSurvey            = "/api/v1/members/create_survey";
  var _urlDelete                  = "/api/v1/members/delete";
  var _urlUnlock                  = "/api/v1/members/unlock";
  var _urlRestore                 = "/api/v1/members/restore";
  var _urlGenerateMissingAccounts = "/api/v1/members/generate_missing_accounts";
  var _memberId;
  var _authenticityToken;

  var _canvas;
  var _signaturePad;

  var _cacheDom = function() {
    _canvas       = document.querySelector("#signature-canvas");
    _signaturePad = new SignaturePad(_canvas);

    $modalGenerateAccessToken       = $("#modal-generate-access-token");
    $modalSignature                 = $("#modal-signature");
    $modalNewLoan                   = $("#modal-new-loan");
    $modalCreateSurvey              = $("#modal-create-survey");
    $modalDelete                    = $("#modal-delete");
    $modalUnlock                    = $("#modal-unlock");
    $modalRestore                   = $("#modal-restore");
    $btnGenerateAccessToken         = $("#btn-generate-access-token");
    $btnConfirmGenerateAccessToken  = $("#btn-confirm-generate-access-token");
    $btnConfirmSignature            = $("#btn-confirm-signature");
    $btnGenerateSignature           = $("#btn-generate-signature");
    $btnClearSignature              = $("#btn-clear-signature");
    $btnNewLoan                     = $("#btn-new-loan");
    $btnCreateSurvey                = $("#btn-create-survey");
    $btnConfirmCreateSurvey         = $("#btn-confirm-create-survey");
    $btnConfirmNewLoan              = $("#btn-confirm-new-loan");
    $btnDelete                      = $("#btn-delete");
    $btnConfirmDelete               = $("#btn-confirm-delete");
    $btnUnlock                      = $("#btn-unlock");
    $btnRestore                     = $("#btn-restore");
    $btnConfirmRestore              = $("#btn-confirm-restore");
    $btnConfirmUnlock               = $("#btn-confirm-unlock");
    $btnGenerateMissingAccounts     = $("#btn-generate-missing-accounts");
    $selectLoanProduct              = $("#select-loan-product");
    $selectSurvey                   = $("#select-survey");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  }

  var _bindEvents = function() {
    $btnGenerateMissingAccounts.on("click", function() {
      $message.html("Generating missing accounts...");

      var data  = {
        id: _memberId,
        authenticity_token: _authenticityToken
      }

      $btnGenerateMissingAccounts.prop("disabled", true);

      $.ajax({
        url: _urlGenerateMissingAccounts,
        method: 'POST',
        data: data,
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

            $btnGenerateMissingAccounts.prop("disabled", false);
          }
        }
      });
    });

    $btnRestore.on("click", function() {
      $message.html("");
      $modalRestore.modal("show");
    });

    $btnConfirmRestore.on("click", function() {
      $message.html("");

      var data  = {
        id: _memberId,
        authenticity_token: _authenticityToken
      }

      $btnConfirmRestore.prop("disabled", true);

      $.ajax({
        url: _urlRestore,
        method: 'POST',
        data: data,
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

            $btnConfirmRestore.prop("disabled", false);
          }
        }
      });
    });

    $btnUnlock.on("click", function() {
      $message.html("");
      $modalUnlock.modal("show");
    });

    $btnConfirmUnlock.on("click", function() {
      $message.html("");

      var data  = {
        id: _memberId,
        authenticity_token: _authenticityToken
      }

      $btnConfirmUnlock.prop("disabled", true);

      $.ajax({
        url: _urlUnlock,
        method: 'POST',
        data: data,
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

            $btnConfirmUnlock.prop("disabled", false);
          }
        }
      });
    });

    $btnDelete.on("click", function() {
      $message.html("");
      $modalDelete.modal("show");
    });

    $btnConfirmDelete.on("click", function() {
      $message.html("");

      var data  = {
        id: _memberId,
        authenticity_token: _authenticityToken
      }

      $btnConfirmDelete.prop("disabled", true);

      $.ajax({
        url: _urlDelete,
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href="/members";
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

    $btnCreateSurvey.on("click", function() {
      $message.html("");
      $modalCreateSurvey.modal("show");
    });

    $btnConfirmCreateSurvey.on("click", function() {
      $message.html("");

      var data  = {
        member_id: _memberId,
        survey_id: $selectSurvey.val(),
        authenticity_token: _authenticityToken
      }

      $selectSurvey.prop("disabled", true);
      $btnConfirmCreateSurvey.prop("disabled", true);

      $.ajax({
        url: _urlCreateSurvey,
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href="/members/" + _memberId + "/survey_answers/" + response.id + "/form";
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

            $btnConfirmCreateSurvey.prop("disabled", false);
            $selectSurvey.prop("disabled", false);
          }
        }
      });
    });

    $btnNewLoan.on("click", function() {
      $message.html("");
      $modalNewLoan.modal("show");
    });

    $btnConfirmNewLoan.on("click", function() {
      var loanProductId = $selectLoanProduct.val();

      $selectLoanProduct.prop("disabled", true);
      $btnConfirmNewLoan.prop("disabled", true);

      $.ajax({
        url: _urlNewLoan,
        method: 'POST',
        data: {
          loan_product_id: loanProductId,
          member_id: _memberId,
          authenticity_token: _authenticityToken
        },
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href="/loans/" + response.id + "/form";
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

            $btnConfirmNewLoan.prop("disabled", false);
            $selectLoanProduct.prop("disabled", false);
          }
        }
      });
    });

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
