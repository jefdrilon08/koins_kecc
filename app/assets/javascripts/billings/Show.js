var Show  = (function() {
  var options;
  var billingId;
  var authenticityToken;

  var $btnApprove;
  var $btnConfirmApprove;
  var $modalApprove;
  
  var $btnCheck;
  var $btnConfirmCheck;
  var $modalCheck;

  var $btnPrint;
  var $btnPrintWp;
  var $modalPrint;

  var $btnZeroOut;
  var $btnConfirmZeroOut;
  var $modalZeroOut;

  var $message;
  var templateErrorList;

  var _urlApprove = "/api/v1/billings/approve";
  var _urlCheck   = "/api/v1/billings/check";
  var _urlZeroOut = "/api/v1/billings/zero_out";
  var _urlPrint   = "/api/v1/print/generate_file";
  var _urlDownload= "/billings/excel";

  var _cacheDom = function() {
    $btnApprove         = $("#btn-approve");
    $btnConfirmApprove  = $("#btn-confirm-approve");
    $modalApprove       = $("#modal-approve");

    $btnCheck         = $("#btn-check");
    $btnConfirmCheck  = $("#btn-confirm-check");
    $modalCheck       = $("#modal-check");

    $btnPrint   = $("#btn-print");
    $btnPrintWp = $("#btn-print-wp");
    $modalPrint = $("#modal-print");
    $btnExcel   = $("#btn-excel");
    $btnZeroOut         = $("#btn-zero-out");
    $btnConfirmZeroOut  = $("#btn-confirm-zero-out");
    $modalZeroOut       = $("#modal-zero-out");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnZeroOut.on("click", function() {
      $modalZeroOut.modal("show");
      $message.html("");
    });

    $btnConfirmZeroOut.on("click", function() {
      $message.html("Loading...");

      $btnConfirmZeroOut.prop("disabled", true);

      $.ajax({
        url: _urlZeroOut,
        method: 'POST',
        dataType: 'json',
        data: {
          id: billingId,
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

            $btnConfirmZeroOut.prop("disabled", false);
          }
        }
      });
    });

    $btnCheck.on("click", function() {
      $modalCheck.modal("show");
      $message.html("");
    });

    $btnConfirmCheck.on("click", function() {
      $btnConfirmCheck.prop("disabled", true);

      $.ajax({
        url: _urlCheck,
        method: 'POST',
        dataType: 'json',
        data: {
          id: billingId,
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

    $btnPrintWp.on("click", function() {
      $modalPrint.modal("show");
      $message.html("");

      $.ajax({
        url: "/api/v1/print/generate_file",
        method: 'POST',
        data: { 
          id: billingId,
          type: "wp",
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

      $btnExcel.on("click", function() {
      
      $.ajax({
        url: _urlDownload,
        method: 'GET',
        data: {
          id: billingId,
          authenticity_token: authenticityToken
        },
        dataType: 'json',
        success: function(response) {
          console.log(response);
          window.open(response.download_url, '_blank');
        },
        error: function(response) {
          $message.html("Error!");
        }
      });
    });


    $btnPrint.on("click", function() {
      $modalPrint.modal("show");

      $.ajax({
        url: "/api/v1/print/generate_file",
        method: 'POST',
        data: { 
          id: billingId,
          type: "billing",
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
          id: billingId,
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
    billingId         = options.billingId;
    authenticityToken = options.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
