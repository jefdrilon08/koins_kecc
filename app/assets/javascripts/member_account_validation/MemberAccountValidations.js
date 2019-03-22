var MemberAccountValidations = (function() {
  var $btnApprove;
  var $btnReverse;
  var $btnValidate;
  var $btnCheck;
  var $btnCancel;

  var $btnApproveConfirmation;
  var $btnApproveValidate;
  var $btnCancelApproval;     
  var $btnCancelValidate;
  var $btnApproveCheck;
  var $btnCancelCheck;
  var $btnApproveCancellation;
  var $btnCancelCancellation;

  var $btnReverseConfirmation;
  var $btnCancelReverse;

  var $parameters;
  var memberAccountValidationId;
  var $errors;
  var $errorsTemplate;
  var urlApproveTransaction             = "/api/v1/member_account_validations/approve";
  var urlReverseTransaction             = "/api/v1/member_account_validations/reverse";
  var urlValidateTransaction            = "/api/v1/member_account_validations/validate";
  var urlCheckTransaction               = "/api/v1/member_account_validations/check";
  var urlCancelTransaction               = "/api/v1/member_account_validations/cancel";
  
  var $modalApprove;
  var $modalValidate;
  var $modalCheck;
  var $modalCancel;
  var $modalReverse;
  var $errors;
  var $errorsTemplate;
  var $modalErrorsApproval;
  var $modalErrorsReverse;
  var $modalErrorsValidate;
  var $modalErrorsCheck;
  var $modalErrorsCancel;
  var $modalSuccessApproval;
  var $modalSuccessReverse;
  var $modalControls;
  var $successTemplate;

  var _displayErrors = function(errors) {
    var errorsDisplay = Mustache.render($errorsTemplate.html(), { errors: errors });
    $errors.html(errorsDisplay);
  }

  var _hideErrors = function() {
    $errors.html("");
  }

  var _addLoadingToConfirmationBtns = function() {
    $btnApproveValidate.addClass('loading');
    $btnApproveValidate.addClass('disabled');
    $btnApproveCheck.addClass('loading');
    $btnApproveCheck.addClass('disabled');
    $btnApproveCancellation.addClass('loading');
    $btnApproveCancellation.addClass('disabled');
    $btnApproveConfirmation.addClass('loading');
    $btnApproveConfirmation.addClass('disabled');
    $btnReverseConfirmation.addClass('loading');
    $btnReverseConfirmation.addClass('disabled');

    $btnCancelApproval.addClass('loading');
    $btnCancelApproval.addClass('disabled');
    $btnCancelReverse.addClass('loading');
    $btnCancelReverse.addClass('disabled');
    $btnCancelValidate.addClass('loading');
    $btnCancelValidate.addClass('disabled');
    $btnCancelCheck.addClass('loading');
    $btnCancelCheck.addClass('disabled');
    $btnCancelCancellation.addClass('loading');
    $btnCancelCancellation.addClass('disabled');
  }

  var _removeLoadingToConfirmationBtns = function() {
    $btnApproveValidate.removeClass('loading');
    $btnApproveValidate.removeClass('disabled');
    $btnApproveCheck.removeClass('loading');
    $btnApproveCheck.removeClass('disabled');
    $btnApproveCancellation.removeClass('loading');
    $btnApproveCancellation.removeClass('disabled');
    $btnApproveConfirmation.removeClass('loading');
    $btnApproveConfirmation.removeClass('disabled');
    $btnReverseConfirmation.removeClass('loading');
    $btnReverseConfirmation.removeClass('disabled');

    $btnCancelValidate.removeClass('loading');
    $btnCancelValidate.removeClass('disabled');
    $btnCancelCheck.removeClass('loading');
    $btnCancelCheck.removeClass('disabled');
    $btnCancelCancellation.removeClass('loading');
    $btnCancelCancellation.removeClass('disabled');
    $btnCancelApproval.removeClass('loading');
    $btnCancelApproval.removeClass('disabled');
    $btnCancelReverse.removeClass('loading');
    $btnCancelReverse.removeClass('disabled');
  }

  var _bindEvents = function() {
    $btnApproveValidate.on("click", function() {
      if(!$btnApproveValidate.hasClass('loading')) {
        _addLoadingToConfirmationBtns();
        $.ajax({
          url: urlValidateTransaction,
          method: 'POST',
          dataType: 'json',
          data: { id: memberAccountValidationId },
          success: function(responseContent) {
            $modalControls.hide();
            window.location.href = "/member_account_validations/" + memberAccountValidationId;
          },
          error: function(responseContent) {
            var errorMessages = JSON.parse(responseContent.responseText).errors;
            console.log(errorMessages);
            $modalErrorsValidate.html(Mustache.render($errorsTemplate.html(), { errors: errorMessages }));
            toastr.error("Something went wrong when trying to validate member account validation: " + errorMessages);
            _removeLoadingToConfirmationBtns();
          }
        });
      } else {
        toastr.info("Still loading");
      }
    });

    $btnApproveCheck.on("click", function() {
      if(!$btnApproveCheck.hasClass('loading')) {
        _addLoadingToConfirmationBtns();
        $.ajax({
          url: urlCheckTransaction,
          method: 'POST',
          dataType: 'json',
          data: { id: memberAccountValidationId },
          success: function(responseContent) {
            $modalControls.hide();
            window.location.href = "/member_account_validations/" + memberAccountValidationId;
          },
          error: function(responseContent) {
            var errorMessages = JSON.parse(responseContent.responseText).errors;
            console.log(errorMessages);
            $modalErrorsCheck.html(Mustache.render($errorsTemplate.html(), { errors: errorMessages }));
            toastr.error("Something went wrong when trying to check member account validation: " + errorMessages);
            _removeLoadingToConfirmationBtns();
          }
        });
      } else {
        toastr.info("Still loading");
      }
    });

    $btnApproveCancellation.on("click", function() {
      if(!$btnApproveCancellation.hasClass('loading')) {
        _addLoadingToConfirmationBtns();
        $.ajax({
          url: urlCancelTransaction,
          method: 'POST',
          dataType: 'json',
          data: { id: memberAccountValidationId },
          success: function(responseContent) {
            $modalControls.hide();
            window.location.href = "/member_account_validations/" + memberAccountValidationId;
          },
          error: function(responseContent) {
            var errorMessages = JSON.parse(responseContent.responseText).errors;
            console.log(errorMessages);
            $modalErrorsCancel.html(Mustache.render($errorsTemplate.html(), { errors: errorMessages }));
            toastr.error("Something went wrong when trying to cancel member account validation: " + errorMessages);
            _removeLoadingToConfirmationBtns();
          }
        });
      } else {
        toastr.info("Still loading");
      }
    });

    $btnApproveConfirmation.on('click', function() {
      if(!$btnApproveConfirmation.hasClass('loading')) {
        _addLoadingToConfirmationBtns();
        $.ajax({
          url: urlApproveTransaction,
          method: 'POST',
          dataType: 'json',
          data: { id: memberAccountValidationId },
          success: function(responseContent) {
            $modalSuccessApproval.html(Mustache.render($successTemplate.html(), { messages: ["Successfully approved transaction"] }));
            $modalControls.hide();
            window.location.href = "/member_account_validations/" + memberAccountValidationId;
          },
          error: function(responseContent) {
            var errorMessages = JSON.parse(responseContent.responseText).errors;
            $modalErrorsApproval.html(Mustache.render($errorsTemplate.html(), { errors: errorMessages }));
            toastr.error("Something went wrong when trying to approve member account validation: " + errorMessages);
            _removeLoadingToConfirmationBtns();
          }
        });
      } else {
        toastr.info("Still loading");
      }
    });

    $btnValidate.on("click", function() {
      $modalValidate.open();
    });

    $btnCheck.on("click", function() {
      $modalCheck.open();
    });

    $btnCancel.on("click", function() {
      $modalCancel.open();
    });

    $btnApprove.on('click', function() {
      $modalSuccessApproval.html("");
      $modalErrorsApproval.html("");
      $modalApprove.open();
    });

    $btnCancelValidate.on('click', function() {
      if(!$btnCancelValidate.hasClass('loading')) {
        $modalValidate.close();
      }
    });

    $btnCancelCheck.on('click', function() {
      if(!$btnCancelCheck.hasClass('loading')) {
        $modalCheck.close();
      }
    });

    $btnCancelCancellation.on('click', function() {
      if(!$btnCancelCancellation.hasClass('loading')) {
        $modalCancel.close();
      }
    });

    $btnCancelApproval.on('click', function() {
      if(!$btnCancelApproval.hasClass('loading')) {
        $modalApprove.close();
      }
    });

    $btnReverseConfirmation.on('click', function() {
      if(!$btnReverseConfirmation.hasClass('loading')) {
        _addLoadingToConfirmationBtns();
        $.ajax({
          url:  urlReverseTransaction,
          method: 'POST',
          dataType: 'json',
          data: { id: memberAccountValidationId },
          success: function(responseContent) {
            $modalSuccessReverse.html(Mustache.render($successTemplate.html(), { messages: ["Successfully reversed transaction"] }));
            $modalControls.hide();
            window.location.href = "/member_account_validations/" + memberAccountValidationId;
          },
          error: function(responseContent) {
            var errorMessages = JSON.parse(responseContent.responseText).errors;
            console.log(errorMessages);
            $modalErrorsReverse.html(Mustache.render($errorsTemplate.html(), { errors: errorMessages }));
            toastr.error("Something went wrong when trying to reverse transaction");
            _removeLoadingToConfirmationBtns();
          }
        });
      } else {
        toastr.error("Still loading");
      }
    });

    $btnCancelReverse.on('click', function() {
      if($btnCancelReverse.hasClass('loading')) {
        toastr.info("Still loading");
      } else {
        $modalReverse.close();
      }
    });

    $btnReverse.on('click', function() {
      $modalSuccessApproval.html("");
      $modalErrorsReverse.html("");
      $modalReverse.open();
    });
  }

  var _cacheDom = function() {
    $confirmationModal           = $("#confirmation-modal"); 
    $btnApprove                  = $("#btn-approve");
    $btnValidate                 = $("#btn-validate");
    $btnCheck                    = $("#btn-check");
    $btnCancel                   = $("#btn-cancel");
    $btnReverse                  = $("#btn-reverse");
    $btnCancelApproval           = $("#btn-cancel-approval");
    $btnCancelValidate           = $("#btn-cancel-validate");
    $btnCancelCheck              = $("#btn-cancel-check");
    $btnCancelCancellation       = $("#btn-cancel-cancellation");
    $btnReverseConfirmation      = $("#btn-confirm-reversal");
    $btnCancelReverse            = $("#btn-cancel-reversal");
    $btnApproveConfirmation      = $("#btn-confirm-approval");
    $btnApproveValidate          = $("#btn-confirm-validate");
    $btnApproveCheck             = $("#btn-confirm-check");
    $btnApproveCancellation      = $("#btn-confirm-cancellation");
    $parameters                  = $("#parameters");
    memberAccountValidationId = $parameters.data("member-account-validation-id");
    $errors                      = $("#errors");
    $errorsTemplate              = $("#errors-template");
    
    $modalValidate               = $(".modal-validate-confirmation").remodal({ hashTracking: true, closeOnOutsideClick: false });
    $modalCheck                  = $(".modal-check-confirmation").remodal({ hashTracking: true, closeOnOutsideClick: false });
    $modalApprove                = $(".modal-approve-confirmation").remodal({ hashTracking: true, closeOnOutsideClick: false });
    $modalReverse                = $(".modal-reverse-confirmation").remodal({ hashTracking: true, closeOnOutsideClick: false });
    $modalCancel                 = $(".modal-cancel-confirmation").remodal({ hashTracking: true, closeOnOutsideClick: false });

    $modalErrorsApproval          = $(".modal-approve").find(".errors");
    $modalErrorsReverse           = $(".modal-reverse").find(".errors");
    $modalErrorsValidate          = $(".modal-validate").find(".errors");
    $modalErrorsCheck             = $(".modal-check").find(".errors");
    $modalErrorsCancel             = $(".modal-cancel").find(".errors"); 
    $modalSuccessApproval         = $(".modal-approve").find(".success");
    $modalSuccessReverse          = $(".modal-reverse").find(".success");
    $modalControls                = $(".modal-controls");
    $successTemplate              = $("#success-template");
  }

  var init = function() {
    _cacheDom();
    _bindEvents();
  }

  return {
    init: init
  };
})();
