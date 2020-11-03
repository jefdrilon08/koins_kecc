import Mustache from "mustache/mustache";

var $btnConfirmApprove;
var $btnConfirmPost;
var $btnConfirmCheck;
var $btnConfirmPending;

var $btnSaveNote;

var $btnApprove;
var $btnPost;
var $btnCheck;
var $btnPending;

var $btnNote;
var $inputNote;

var $btnConfirmBook;

var $errors;
var $errorsTemplate;
var urlApproveTransaction     = "/api/v1/claims/approve";
var urlPostTransaction        = "/api/v1/claims/post";
var urlCheckTransaction       = "/api/v1/claims/check";
var urlPendingTransaction     = "/api/v1/claims/pending";
var urlModifyClaimsTemplate   = "/api/v1/claims/modify_claims_template";
var urlModifyBook             = "/api/v1/claims/modify_book";
var urlModifyParticular       = "/api/v1/claims/modify_particular";
var urlSaveCheckNumber        = "/api/v1/claims/save_check_number";
var urlSaveCheckVoucherNumber = "/api/v1/claims/save_check_voucher_number";
var urlSavePayee              = "/api/v1/claims/save_payee";
var urlSaveNote               = "/api/v1/claims/save_note";

var $modalApprove;
var $modalCheck;
var $modalPost;
var $modalPending;

var $modalNote;

var $errors;
var $errorsTemplate;
var $modalErrorsApproval;
var $modalErrorsChecking;
var $modalErrorsPosting;
var $modalErrorsPending;
var $modalSuccessApproval;
var $modalSuccessChecking;
var $modalSuccessPosting;
var $modalSuccessPending;
var $modalControls;
var $successTemplate;

var $confirmationModal;

var $message;
var templateErrorList;

var authenticityToken;
var claimId;

var $selectClaimsTemplate;
var $btnConfirmBook;

var $selectBook;
var $btnConfirmClaimsTemplate;

var $inputTextParticular;
var $btnConfirmParticular;

var $inputTextPayee;
var $btnConfirmPayee;

var $inputTextCheckNumber;
var $btnConfirmCheckNumber;

var $inputTextCheckVoucherNumber;
var $btnConfirmCheckVoucherNumber;

var $btnPrint;
var $modalPrint;
var $printMessage;

var loader;

var _bindEvents = function() {

  // Check
  $btnConfirmCheck.on("click", function() {
    $btnConfirmCheck.prop("disabled", true);

    $.ajax({
      url: urlCheckTransaction,
      method: 'POST',
      dataType: 'json',
      data: {
        id: claimId,
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

          $btnConfirmCheck.prop("disabled", false);
        }
      }
    });
  });

  // Pending
  $btnConfirmPending.on("click", function() {
    $btnConfirmPending.prop("disabled", true);

    $.ajax({
      url: urlPendingTransaction,
      method: 'POST',
      dataType: 'json',
      data: {
        id: claimId,
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

          $btnConfirmPending.prop("disabled", false);
        }
      }
    });
  });

  // Approve
  $btnConfirmApprove.on("click", function() {
    $btnConfirmApprove.prop("disabled", true);

    $.ajax({
      url: urlApproveTransaction,
      method: 'POST',
      dataType: 'json',
      data: {
        id: claimId,
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

          $btnConfirmApprove.prop("disabled", false);
        }
      }
    });
  });

  // POST
  $btnConfirmPost.on("click", function() {
    $btnConfirmPost.prop("disabled", true);

    $.ajax({
      url: urlPostTransaction,
      method: 'POST',
      dataType: 'json',
      data: {
        id: claimId,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html("Success! Redirecting...");
        // window.location.reload();
        window.location.href="/claims";
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

          $btnConfirmPost.prop("disabled", false);
        }
      }
    });
  });

  $btnConfirmClaimsTemplate.on("click", function() {
    var template  = $selectClaimsTemplate.val();

    $message.html("Loading...");

    $selectClaimsTemplate.prop("disabled", true);
    $btnConfirmClaimsTemplate.prop("disabled", true);

    $.ajax({
      url: urlModifyClaimsTemplate,
      method: 'POST',
      data: { 
        id: claimId,
        template: template,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );

        window.location.reload();
      },
      error: function(response) {
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

          $selectClaimsTemplate.prop("disabled", false);
          $btnConfirmClaimsTemplate.prop("disabled", false);
        }
      }
    });
  });

  $btnConfirmParticular.on("click", function() {
    var particular  = $inputTextParticular.val();

    $message.html("Loading...");

    $inputTextParticular.prop("disabled", true);
    $btnConfirmParticular.prop("disabled", true);

    $.ajax({
      url: urlModifyParticular,
      method: 'POST',
      data: { 
        id: claimId,
        particular: particular,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );

        window.location.reload();
      },
      error: function(response) {
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

          $inputTextParticular.prop("disabled", false);
          $btnConfirmParticular.prop("disabled", false);
        }
      }
    });
  });

  $btnConfirmPayee.on("click", function() {
    var payee  = $inputTextPayee.val();

    $message.html("Loading...");

    $inputTextPayee.prop("disabled", true);
    $btnConfirmPayee.prop("disabled", true);

    $.ajax({
      url: urlSavePayee,
      method: 'POST',
      data: { 
        id: claimId,
        payee: payee,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );

        window.location.reload();
      },
      error: function(response) {
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

          $inputTextPayee.prop("disabled", false);
          $btnConfirmPayee.prop("disabled", false);
        }
      }
    });
  });

  $btnConfirmCheckNumber.on("click", function() {
    var check_number  = $inputTextCheckNumber.val();

    $message.html("Loading...");

    $inputTextCheckNumber.prop("disabled", true);
    $btnConfirmCheckNumber.prop("disabled", true);

    $.ajax({
      url: urlSaveCheckNumber,
      method: 'POST',
      data: { 
        id: claimId,
        check_number: check_number,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );

        window.location.reload();
      },
      error: function(response) {
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

          $inputTextCheckNumber.prop("disabled", false);
          $btnConfirmCheckNumber.prop("disabled", false);
        }
      }
    });
  });

  $btnConfirmCheckVoucherNumber.on("click", function() {
    var check_voucher_number  = $inputTextCheckVoucherNumber.val();

    $message.html("Loading...");

    $inputTextCheckVoucherNumber.prop("disabled", true);
    $btnConfirmCheckVoucherNumber.prop("disabled", true);

    $.ajax({
      url: urlSaveCheckVoucherNumber,
      method: 'POST',
      data: { 
        id: claimId,
        check_voucher_number: check_voucher_number,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );

        window.location.reload();
      },
      error: function(response) {
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

          $inputTextCheckVoucherNumber.prop("disabled", false);
          $btnConfirmCheckVoucherNumber.prop("disabled", false);
        }
      }
    });
  });

  $btnConfirmBook.on("click", function() {
    var book  = $selectBook.val();

    $message.html("Loading...");

    $selectBook.prop("disabled", true);
    $btnConfirmBook.prop("disabled", true);

    $.ajax({
      url: urlModifyBook,
      method: 'POST',
      data: { 
        id: claimId,
        book: book,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );

        window.location.reload();
      },
      error: function(response) {
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

          $selectBook.prop("disabled", false);
          $btnConfirmBook.prop("disabled", false);
        }
      }
    });
  });


  $btnSaveNote.on("click", function() {
    var note  = $inputNote.val();

    $message.html("Loading...");

    $inputNote.prop("disabled", true);
    $btnSaveNote.prop("disabled", true);

    $.ajax({
      url: urlSaveNote,
      method: 'POST',
      data: { 
        id: claimId,
        note: note,
        authenticity_token: authenticityToken
      },
      success: function(response) {
        $message.html(
          "Success! Redirecting..."
        );

        window.location.reload();
      },
      error: function(response) {
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

          $inputNote.prop("disabled", false);
          $btnSaveNote.prop("disabled", false);
        }
      }
    });
  });

  // check
  $btnCheck.on("click", function() {
    $modalCheck.modal("show");
    $message.html("");
  });

  // Add note
  $btnNote.on("click", function() {
    $modalNote.modal("show");
    $message.html("");
  });

  // Approve
  $btnApprove.on("click", function() {
    $modalApprove.modal("show");
    $message.html("");
  });

  // Post
  $btnPost.on("click", function() {
    $modalPost.modal("show");
    $message.html("");
  });

  // Pending
  $btnPending.on("click", function() {
    $modalPending.modal("show");
    $message.html("");
  });

  $btnPrint.on("click", function() {
    var accountingEntryId = $btnPrint.data('id');
    var cId = $btnPrint.data('cid');

    $modalPrint.modal("show");
    $printMessage.html(
      Mustache.render(
        loader,
        {}
      )
    );

    $modalPrint.modal("hide");
    window.open("/print?id=" + accountingEntryId + "&type=claims_voucher" + "&cid=" + cId);
  });
}

var _cacheDom = function() {
  $confirmationModal            = $("#confirmation-modal"); 
  $btnApprove                   = $("#btn-approve");
  $btnCheck                     = $("#btn-check");
  $btnPost                      = $("#btn-post");
  $btnPending                   = $("#btn-pending");

  $btnNote                      = $("#btn-note");

  $btnConfirmApprove            = $("#btn-confirm-approval");
  $btnConfirmCheck              = $("#btn-confirm-check");
  $btnConfirmPost               = $("#btn-confirm-posting");
  $btnConfirmPending            = $("#btn-confirm-pending");

  $btnSaveNote                  = $("#btn-save-note");
  $inputNote                    = $("#input-note");

  $errors                       = $("#errors");
  $errorsTemplate               = $("#errors-template");
  
  // Validate
  $modalCheck                   = $("#modal-check-confirmation");
  $modalApprove                 = $("#modal-approve-confirmation");
  $modalPost                    = $("#modal-post-confirmation");
  $modalPending                 = $("#modal-pending-confirmation");

  $modalNote                    = $("#modal-note");

  
  $modalErrorsApproval          = $(".modal-approve").find(".errors");
  $modalErrorsChecking          = $(".modal-check").find(".errors");
  $modalErrorsPosting           = $(".modal-post").find(".errors");
  $modalErrorsPending           = $(".modal-pending").find(".errors");

  $modalSuccessApproval         = $(".modal-approve").find(".success");
  $modalSuccessChecking         = $(".modal-check").find(".success");
  $modalSuccessPosting          = $(".modal-post").find(".success");
  $modalSuccessPending          = $(".modal-pending").find(".success");

  $modalControls                = $(".modal-controls");
  $successTemplate              = $("#success-template");

  $message                      = $(".message");
  templateErrorList             = $("#template-error-list").html();

  $selectClaimsTemplate         = $("#select-claims-template");
  $btnConfirmClaimsTemplate     = $("#btn-confirm-claims-template");

  $inputTextParticular          = $("#input-text-particular");
  $btnConfirmParticular         = $("#btn-confirm-particular");

  $inputTextPayee               = $("#input-text-payee");
  $btnConfirmPayee              = $("#btn-confirm-payee");

  $inputTextCheckNumber         = $("#input-text-check-number");
  $btnConfirmCheckNumber        = $("#btn-confirm-check-number");

  $inputTextCheckVoucherNumber  = $("#input-text-check-voucher-number");
  $btnConfirmCheckVoucherNumber = $("#btn-confirm-check-voucher-number");

  $selectBook                   = $("#select-book");
  $btnConfirmBook               = $("#btn-confirm-book");

  $btnPrint                     = $("#btn-print");
  $modalPrint                   = $("#modal-print");
  $printMessage                 = $(".print-message");

  loader                        = $("#template-loader").html();
}

var init = function(options) {
  authenticityToken  = options.authenticityToken;
  claimId            = options.id;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
