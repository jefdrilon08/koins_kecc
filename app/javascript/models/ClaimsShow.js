import Mustache from "mustache/mustache";

var $btnConfirmApprove;
var $btnConfirmPost;
var $btnConfirmCheck;

var $btnApprove;
var $btnPost;
var $btnCheck;

var $btnConfirmBook;

var $errors;
var $errorsTemplate;
var urlApproveTransaction     = "/api/v1/claims/approve";
var urlPostTransaction        = "/api/v1/claims/post";
var urlCheckTransaction       = "/api/v1/claims/check";
var urlModifyClaimsTemplate   = "/api/v1/claims/modify_claims_template";
var urlModifyBook             = "/api/v1/claims/modify_book";
var urlModifyParticular       = "/api/v1/claims/modify_particular";

var $modalApprove;
var $modalCheck;
var $modalPost;
var $errors;
var $errorsTemplate;
var $modalErrorsApproval;
var $modalErrorsChecking;
var $modalErrorsPosting;
var $modalSuccessApproval;
var $modalSuccessChecking;
var $modalSuccessPosting;
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

  // check
  $btnCheck.on("click", function() {
    $modalCheck.modal("show");
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
}

var _cacheDom = function() {
  $confirmationModal            = $("#confirmation-modal"); 
  $btnApprove                   = $("#btn-approve");
  $btnCheck                     = $("#btn-check");
  $btnPost                      = $("#btn-post");

  $btnConfirmApprove            = $("#btn-confirm-approval");
  $btnConfirmCheck              = $("#btn-confirm-check");
  $btnConfirmPost               = $("#btn-confirm-posting");

  $errors                       = $("#errors");
  $errorsTemplate               = $("#errors-template");
  
  // Validate
  $modalCheck                   = $("#modal-check-confirmation");
  $modalApprove                 = $("#modal-approve-confirmation");
  $modalPost                    = $("#modal-post-confirmation");

  
  $modalErrorsApproval          = $(".modal-approve").find(".errors");
  $modalErrorsChecking          = $(".modal-check").find(".errors");
  $modalErrorsPosting           = $(".modal-post").find(".errors");

  $modalSuccessApproval         = $(".modal-approve").find(".success");
  $modalSuccessChecking         = $(".modal-check").find(".success");
  $modalSuccessPosting          = $(".modal-post").find(".success");

  $modalControls                = $(".modal-controls");
  $successTemplate              = $("#success-template");

  $message                      = $(".message");
  templateErrorList             = $("#template-error-list").html();

  $selectClaimsTemplate         = $("#select-claims-template");
  $btnConfirmClaimsTemplate     = $("#btn-confirm-claims-template");

  $inputTextParticular          = $("#input-text-particular");
  $btnConfirmParticular         = $("#btn-confirm-particular");

  $selectBook                   = $("#select-book");
  $btnConfirmBook               = $("#btn-confirm-book");
}

var init = function(options) {
  authenticityToken  = options.authenticityToken;
  claimId            = options.id;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
