var Show  = (function() {
  var options;
  var depositCollectionId;
  var authenticityToken;

  var $btnApprove;
  var $btnConfirmApprove;
  var $modalApprove;

  var $btnPrint;
  var $modalPrint;

  var $selectCashManagementTemplate;
  var $btnConfirmCashManagementTemplate;

  var $message;
  var templateErrorList;

  var _urlApprove = "/api/v1/deposit_collections/approve";
  var _urlPrint   = "/api/v1/print/generate_file";

  var _cacheDom = function() {
    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $modalApprove       = $("#modal-approve");

    $btnPrint   = $("#btn-print");
    $modalPrint = $("#modal-print");

    $selectCashManagementTemplate     = $("#select-cash-management-template");
    $btnConfirmCashManagementTemplate = $("#btn-confirm-cash-management-template");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnConfirmCashManagementTemplate.on("click", function() {
      var template  = $selectCashManagementTemplate.val();

      $message.html("Loading...");

      $selectCashManagementTemplate.prop("disabled", true);
      $btnConfirmCashManagementTemplate.prop("disabled", true);

      $.ajax({
        url: "/api/v1/deposit_collections/modify_cash_management_template",
        method: 'POST',
        data: { 
          id: depositCollectionId,
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

            $selectCashManagementTemplate.prop("disabled", false);
            $btnConfirmCashManagementTemplate.prop("disabled", false);
          }
        }
      });
    });

    $btnPrint.on("click", function() {
      $modalPrint.modal("show");

      $.ajax({
        url: "/api/v1/print/generate_file",
        method: 'POST',
        data: { 
          id: depositCollectionId,
          type: "deposit_collection",
          authenticity_token: authenticityToken
        },
        success: function(response) {
          $message.html(
            "Success! Redirecting..."
          );

          $modalPrint.modal("hide");
          window.open("/print?filename=" + response.filename, '_blank');
        },
        error: function(response) {
          $message.html("Error!");
        }
      });
    });

    $btnApprove.on("click", function() {
      $message.html("");
      $modalApprove.modal("show");
    });

    $btnConfirmApprove.on("click", function() {
      $message.html("Loading...");
      $btnConfirmApprove.prop("disabled", true);

      $.ajax({
        url: _urlApprove,
        method: 'POST',
        dataType: 'json',
        data: {
          id: depositCollectionId,
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
  };

  var init  = function(options) {
    depositCollectionId = options.depositCollectionId;
    authenticityToken   = options.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
