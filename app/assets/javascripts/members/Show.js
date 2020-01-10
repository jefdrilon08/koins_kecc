var Show  = (function() {
  var $modalGenerateAccessToken;
  var $modalSignature;
  var $modalNewLoan;
  var $modalDelete;
  var $modalCreateSurvey;
  var $modalRestore;
  var $modalUnlock;
  var $modalChangeMemberType;
  var $modalChangeRecognitionDate;
  var $modalUploadProfilePicture;
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
  var $btnChangeMemberType;
  var $btnChangeRecognitionDate;
  var $btnConfirmChangeMemberType;
  var $btnConfirmChangeRecognitionDate;
  var $btnUploadProfilePicture;
  var $btnConfirmUploadProfilePicture;
  var $inputRecognitionDate;
  var $selectLoanProduct;
  var $selectSurvey;
  var $selectMemberType;
  var $message;
  var $btnResignFromInsurance;   
  var $modalResignFromInsurance; 
  var $btnConfirmInsuranceResign;
  var $inputDateResigned;
  var $inputReason;
  var $fileProfilePicture;
  var templateErrorList;


  var _urlGenerateAccessToken     = "/api/v1/members/generate_access_token";
  var _urlSaveSignature           = "/api/v1/members/save_signature";
  var _urlNewLoan                 = "/api/v1/loans/apply";
  var _urlCreateSurvey            = "/api/v1/members/create_survey";
  var _urlDelete                  = "/api/v1/members/delete";
  var _urlUnlock                  = "/api/v1/members/unlock";
  var _urlRestore                 = "/api/v1/members/restore";
  var _urlGenerateMissingAccounts = "/api/v1/members/generate_missing_accounts";
  var _urlChangeMemberType        = "/api/v1/members/change_member_type";
  var _urlChangeRecognitionDate   = "/api/v1/members/change_recognition_date";
  var _urlResignFromInsurance     = "/api/v1/members/resign";
  var _urlUploadProfilePicture    = "/api/v1/members/upload_profile_picture";
  var _memberId;
  var _authenticityToken;

  var _canvas;
  var _signaturePad;

  var _cacheDom = function() {
    _canvas       = document.querySelector("#signature-canvas");
    _signaturePad = new SignaturePad(_canvas);

    $modalGenerateAccessToken         = $("#modal-generate-access-token");
    $modalSignature                   = $("#modal-signature");
    $modalNewLoan                     = $("#modal-new-loan");
    $modalCreateSurvey                = $("#modal-create-survey");
    $modalDelete                      = $("#modal-delete");
    $modalUnlock                      = $("#modal-unlock");
    $modalRestore                     = $("#modal-restore");
    $modalChangeMemberType            = $("#modal-change-member-type");
    $modalChangeRecognitionDate       = $("#modal-change-recognition-date");
    $modalUploadProfilePicture        = $("#modal-upload-profile-picture");
    $btnGenerateAccessToken           = $("#btn-generate-access-token");
    $btnConfirmGenerateAccessToken    = $("#btn-confirm-generate-access-token");
    $btnConfirmSignature              = $("#btn-confirm-signature");
    $btnGenerateSignature             = $("#btn-generate-signature");
    $btnClearSignature                = $("#btn-clear-signature");
    $btnNewLoan                       = $("#btn-new-loan");
    $btnCreateSurvey                  = $("#btn-create-survey");
    $btnConfirmCreateSurvey           = $("#btn-confirm-create-survey");
    $btnConfirmNewLoan                = $("#btn-confirm-new-loan");
    $btnDelete                        = $("#btn-delete");
    $btnConfirmDelete                 = $("#btn-confirm-delete");
    $btnUnlock                        = $("#btn-unlock");
    $btnRestore                       = $("#btn-restore");
    $btnConfirmRestore                = $("#btn-confirm-restore");
    $btnConfirmUnlock                 = $("#btn-confirm-unlock");
    $btnGenerateMissingAccounts       = $("#btn-generate-missing-accounts");
    $btnChangeMemberType              = $("#btn-change-member-type");
    $btnChangeRecognitionDate         = $("#btn-change-recognition-date");
    $btnConfirmChangeMemberType       = $("#btn-confirm-change-member-type");
    $btnConfirmChangeRecognitionDate  = $("#btn-confirm-change-recognition-date");
    $inputRecognitionDate             = $("#input-recognition-date");
    $fileProfilePicture               = $("#file-profile-picture");
    $selectMemberType                 = $("#select-member-type");
    $selectLoanProduct                = $("#select-loan-product");
    $selectSurvey                     = $("#select-survey");
    $btnResignFromInsurance           = $("#btn-resign-from-insurance");
    $modalResignFromInsurance         = $("#modal-resign-from-insurance");
    $btnConfirmInsuranceResign        = $("#btn-confirm-insurance-resign");
    $btnUploadProfilePicture          = $("#btn-upload-profile-picture");
    $btnConfirmUploadProfilePicture   = $("#btn-confirm-upload-profile-picture");
    $inputDateResigned                = $("#input-date-resigned");
    $inputReason                      = $("#input-reason");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  }

  var _bindEvents = function() {
    $btnUploadProfilePicture.on("click", function() {
      $message.html("");
      $modalUploadProfilePicture.modal("show");
    });

    $btnConfirmUploadProfilePicture.on("click", function() {
      $message.html("Uploading profile picture...");
      $btnConfirmUploadProfilePicture.prop("disabled", true);

      errors  = [];

      if($fileProfilePicture[0].files.length == 0) {
        errors.push("Profile picture required");

        $message.html("Profile picture required...");
        $btnConfirmUploadProfilePicture.prop("disabled", false);
      }

      if(errors.length == 0) {
        var formData  = new FormData();
        var files     = [];

        files.push({
          name: "PROFILE_PICTURE",
          file: $fileProfilePicture[0].files[0]
        });

        for(var i = 0; i < files.length; i++) {
          formData.append("files[]", files[i].file);
          formData.append("file_types[]", files[i].name);

          formData.append("id", _memberId);

          $.ajax({
            url: _urlUploadProfilePicture,
            method: 'POST',
            contentType: false,
            processData: false,
            data: formData,
            success: function(response) {
              $message.html("Success! Reloading...");
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

                $btnConfirmUploadProfilePicture.prop("disabled", false);
              }
            }
          });
        }
      }
    });

    $btnChangeRecognitionDate.on("click", function() {
      $message.html(""); 
      $modalChangeRecognitionDate.modal("show");
    });

    $btnConfirmChangeRecognitionDate.on("click", function() {
      $message.html("Changing member recognition date...");

      var data  = {
        id: _memberId,
        recognition_date: $inputRecognitionDate.val(),
        authenticity_token: _authenticityToken
      }

      $btnConfirmChangeRecognitionDate.prop("disabled", true);

      $.ajax({
        url: _urlChangeRecognitionDate,
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

            $btnConfirmChangeRecognitionDate.prop("disabled", false);
          }
        }
      });
    });

    $btnChangeMemberType.on("click", function() {
      $message.html(""); 
      $modalChangeMemberType.modal("show");
    });

    $btnConfirmChangeMemberType.on("click", function() {
      $message.html("Changing member type...");

      var data  = {
        id: _memberId,
        member_type: $selectMemberType.val(),
        authenticity_token: _authenticityToken
      }

      $btnConfirmChangeMemberType.prop("disabled", true);

      $.ajax({
        url: _urlChangeMemberType,
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

            $btnConfirmChangeMemberType.prop("disabled", false);
          }
        }
      });
    });

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

    $btnResignFromInsurance.on("click", function() {
      $modalResignFromInsurance.modal("show");

      $btnConfirmInsuranceResign.on("click", function() {
        $btnConfirmInsuranceResign.prop("disabled", true);
        //alert("hello");
          $.ajax({
          url: _urlResignFromInsurance,
          method: 'POST',
          dataType: 'json',
          data: { 
            member_id: _memberId,
            date_resigned: $inputDateResigned.val(),
            reason: $inputReason.val(),
            authenticity_token: _authenticityToken
          },
          success: function(response) {
            $message.html("Successfully resigned member");
            window.location.reload();
          },
          error: function(response) {
            $message.html("Error in generating access_token");
            $btnConfirmInsuranceResign.prop("disabled", false);
          }
        });

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
