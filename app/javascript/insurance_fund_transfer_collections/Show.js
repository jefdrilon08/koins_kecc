import Mustache from "mustache/mustache";

var Show  = (function() {
  var options;
  var insuranceFundTransferCollectionId;
  var authenticityToken;

  var $btnApprove;
  var $btnConfirmApprove;
  var $modalApprove;

  var $btnFinalize;
  var $btnConfirmFinalize;
  var $modalFinalize;

  var $btnPrint;
  var $modalPrint;

  var $message;
  var templateErrorList;

  var _urlApprove   = "/api/v1/insurance_fund_transfer_collections/approve";
  var _urlPrint     = "/api/v1/print/generate_file";
  var _urlFinalize  = "/api/v1/insurance_fund_transfer_collections/finalize";

  var _cacheDom = function() {
    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $modalApprove       = $("#modal-approve");

    $btnFinalize        = $("#btn-finalize");
    $btnConfirmFinalize = $("#btn-confirm-finalize");
    $modalFinalize      = $("#modal-finalize");

    $btnPrint   = $("#btn-print");
    $modalPrint = $("#modal-print");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnPrint.on("click", function() {
      $modalPrint.modal("show");

      $.ajax({
        url: "/api/v1/print/generate_file",
        method: 'POST',
        data: { 
          id: insuranceFundTransferCollectionId,
          type: "insurance_fund_transfer_collection",
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


    $btnFinalize.on("click", function() {
      $message.html("");
      $modalFinalize.modal("show");
    });

    $btnConfirmFinalize.on("click", function() {
      $message.html("Loading...");
      $btnConfirmFinalize.prop("disabled", true);

      $.ajax({
        url: _urlFinalize,
        method: 'POST',
        dataType: 'json',
        data: {
          id: insuranceFundTransferCollectionId,
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

            $btnConfirmFinalize.prop("disabled", false);
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
      $btnConfirmApprove.prop("disabled", true);

      $.ajax({
        url: _urlApprove,
        method: 'POST',
        dataType: 'json',
        data: {
          id: insuranceFundTransferCollectionId,
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
    insuranceFundTransferCollectionId = options.insuranceFundTransferCollectionId;
    authenticityToken   = options.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();

window.InsuranceFundTransferCollectionsShow = Show;
