var Show = (function() {
  var _authenticityToken;
  var _id;

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

  var $displayMember;
  var $displayAccountSubtype;

  var $message;

  var templateErrorList;

  var currentMember           = "";
  var currentMemberAccountId  = "";
  var currentAccountSubtype   = "";

  var _urlDelete        = "/api/v1/adjustments/subsidiary_adjustments/destroy";
  var _urlAdd           = "/api/v1/adjustments/subsidiary_adjustments/add_member";
  var _urlDeleteMember  = "/api/v1/adjustments/subsidiary_adjustments/delete_member";

  var _cacheDom = function() {
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

    $displayMember          = $(".display-member");
    $displayAccountSubtype  = $(".display-account-subtype");

    $message  = $(".message");

    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
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
