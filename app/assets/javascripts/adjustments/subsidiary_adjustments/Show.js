var Show = (function() {
  var _authenticityToken;
  var _id;

  var $btnApprove;
  var $btnConfirmApprove;
  var $modalApprove;

  var $btnDelete;
  var $btnConfirmDelete;
  var $modalDelete;

  var $selectMember;
  var $selectAccount;
  var $selectAdjustment;
  var $inputAmount;
  var $btnAdd;

  var $btnDeleteMember;
  var $btnConfirmDeleteMember;
  var $modalDeleteMember;

  var $selectAccountingCode;
  var $inputAmount;
  var $selectPostType;
  var $btnAddAccountingCode;

  var $btnDeleteAccountingEntry;
  var $btnConfirmDeleteAccountingEntry;
  var $modalDeleteAccountingEntry;

  var $inputParticular;
  var $btnUpdateAccountingEntryParticular;

  var $displayMember;
  var $displayAccountSubtype;
  var $displayPostType;
  var $displayAccountingCode;

  var $message;

  var templateErrorList;

  var currentMember           = "";
  var currentMemberAccountId  = "";
  var currentAccountSubtype   = "";
  var currentAccountingCodeId = "";
  var currentPostType         = "";

  var _urlApprove                         = "/api/v1/adjustments/subsidiary_adjustments/approve";
  var _urlDelete                          = "/api/v1/adjustments/subsidiary_adjustments/destroy";
  var _urlAdd                             = "/api/v1/adjustments/subsidiary_adjustments/add_member";
  var _urlDeleteMember                    = "/api/v1/adjustments/subsidiary_adjustments/delete_member";
  var _urlAddAccountingCode               = "/api/v1/adjustments/subsidiary_adjustments/add_accounting_code";
  var _urlDeleteAccountingCode            = "/api/v1/adjustments/subsidiary_adjustments/delete_accounting_code";
  var _urlUpdateAccountingEntryParticular = "/api/v1/adjustments/subsidiary_adjustments/update_accounting_entry_particular";

  var _cacheDom = function() {
    $inputParticular                    = $("#input-particular");
    $btnUpdateAccountingEntryParticular = $("#btn-update-accounting-entry-particular");

    $btnDeleteAccountingEntry   = $("#btn-delete-accounting-entry");
    $modalDeleteAccountingEntry = $("#modal-delete-accounting-entry");

    $selectAccountingCode   = $("#select-accounting-code");
    $inputAccountingAmount  = $("#input-accounting-amount");
    $selectPostType         = $("#select-post-type");
    $btnAddAccountingCode   = $("#btn-add-accounting-code");

    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $modalApprove       = $("#modal-approve");

    $btnDelete         = $("#btn-delete");
    $btnConfirmDelete  = $("#btn-confirm-delete");
    $modalDelete       = $("#modal-delete");

    $selectMember     = $("#select-member");
    $selectAccount    = $("#select-account");
    $selectAdjustment = $("#select-adjustment");
    $inputAmount      = $("#input-amount");
    $btnAdd           = $("#btn-add");

    $btnDeleteMember        = $(".btn-delete-member");
    $btnConfirmDeleteMember = $("#btn-confirm-delete-member");
    $modalDeleteMember      = $("#modal-delete-member");

    $btnDeleteAccountingEntry         = $(".btn-delete-accounting-entry");
    $btnConfirmDeleteAccountingEntry  = $("#btn-confirm-delete-accounting-entry");
    $modalDeleteAccountingEntry       = $("#modal-delete-accounting-entry");

    $displayMember          = $(".display-member");
    $displayAccountSubtype  = $(".display-account-subtype");
    $displayPostType        = $(".display-post-type");
    $displayAccountingCode  = $(".display-accounting-code");

    $message  = $(".message");

    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnUpdateAccountingEntryParticular.on("click", function() {
      $message.html("Loading...");

      var particular  = $inputParticular.val();

      var data  = {
        id: _id,
        authenticity_token: _authenticityToken,
        particular: particular
      };

      $btnUpdateAccountingEntryParticular.prop("disabled", true);
      $inputParticular.prop("disabled", true);

      $.ajax({
        url: _urlUpdateAccountingEntryParticular,
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );
          
          window.location.reload();
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

            $btnUpdateAccountingEntryParticular.prop("disabled", false);
            $inputParticular.prop("disabled", false);
          }
        }
      });
    });

    $btnApprove.on("click", function() {
      $message.html("");
      $modalApprove.modal("show");
    });

    $btnConfirmApprove.on("click", function() {
      $message.html("Loading...");

      var data  = {
        id: _id,
        authenticity_token: _authenticityToken
      };

      $btnConfirmApprove.prop("disabled", true);

      $.ajax({
        url: _urlApprove,
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );
          
          window.location.reload();
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

            $btnConfirmApprove.prop("disabled", false);
          }
        }
      });
    });

    $btnDeleteAccountingEntry.on("click", function() {
      $message.html("");
      $modalDeleteAccountingEntry.modal("show");

      $displayPostType.html($(this).data("post-type"));
      $displayAccountingCode.html($(this).data("accounting-code-name"));

      currentAccountingCodeId = $(this).data("accounting-code-id");
      currentPostType         = $(this).data("post-type");
    });

    $btnConfirmDeleteAccountingEntry.on("click", function() {
      var data  = {
        id: _id,
        accounting_code_id: currentAccountingCodeId,
        post_type: currentPostType,
        authenticity_token: _authenticityToken
      };

      $btnConfirmDeleteAccountingEntry.prop("disabled", true);

      $.ajax({
        url: _urlDeleteAccountingCode,
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );
          
          window.location.reload();
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

            $btnConfirmDeleteAccountingEntry.prop("disabled", false);
          }
        }
      });
    });

    $btnAddAccountingCode.on("click", function() {
      $message.html("Loading...");

      var accountingCodeId  = $selectAccountingCode.val();
      var amount            = $inputAccountingAmount.val();
      var postType          = $selectPostType.val();

      var data  = {
        id: _id,
        authenticity_token: _authenticityToken,
        accounting_code_id: accountingCodeId,
        amount: amount,
        post_type: postType
      };

      $selectAccountingCode.prop("disabled", true);
      $inputAccountingAmount.prop("disabled", true);
      $selectPostType.prop("disabled", true);
      $btnAddAccountingCode.prop("disabled", true);

      $.ajax({
        url: _urlAddAccountingCode,
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );
          
          window.location.reload();
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

            $selectAccountingCode.prop("disabled", false);
            $inputAccountingAmount.prop("disabled", false);
            $selectPostType.prop("disabled", false);
            $btnAddAccountingCode.prop("disabled", false);
          }
        }
      });
    });

    $btnDeleteMember.on("click", function() {
      $message.html("");

      currentMember           = $(this).data("member-name");
      currentMemberAccountId  = $(this).data("member-account-id");
      currentAccountSubtype   = $(this).data("account-subtype");

      $displayMember.html(currentMember);
      $displayAccountSubtype.html(currentAccountSubtype);

      $modalDeleteMember.modal("show");
    });

    $btnConfirmDeleteMember.on("click", function() {
      $message.html("Loading...");
      $btnConfirmDeleteMember.prop("disabled", true);

      var data  = {
        id: _id,
        member_account_id: currentMemberAccountId,
        authenticity_token: _authenticityToken
      };

      $.ajax({
        url: _urlDeleteMember,
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );
          
          window.location.reload();
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

            $btnConfirmDeleteMember.prop("disabled", false);
          }
        }
      });
    });

    $btnAdd.on("click", function() {
      var memberId        = $selectMember.val();
      var accountSubtype  = $selectAccount.val();
      var adjustment      = $selectAdjustment.val();
      var amount          = $inputAmount.val();

      var data  = {
        id: _id,
        member_id: memberId,
        account_subtype: accountSubtype,
        adjustment: adjustment,
        amount: amount,
        authenticity_token: _authenticityToken
      };

      $selectMember.prop("disabled", true);
      $selectAccount.prop("disabled", true);
      $selectAdjustment.prop("disabled", true);
      $inputAmount.prop("disabled", true);

      $.ajax({
        url: _urlAdd,
        method: 'POST',
        data: data,
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );
          
          window.location.reload();
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

            $selectMember.prop("disabled", false);
            $selectAccount.prop("disabled", false);
            $selectAdjustment.prop("disabled", false);
            $inputAmount.prop("disabled", false);
          }
        }
      });
    });

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
