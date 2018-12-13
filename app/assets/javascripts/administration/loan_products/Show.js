var Show  = (function() {
  var $btnDelete;
  var $btnConfirmDelete;
  var $modalDelete;

  var $btnPrerequisite;
  var $btnConfirmPrerequisite;
  var $modalPrerequisite;
  var $selectLoanProduct;

  var $message;

  var id;
  var authenticityToken;

  var templateErrorList;

  var _urlDelete              = "/api/v1/administration/loan_products/delete";
  var _urlModifyPrerequisite  = "/api/v1/administration/loan_products/modify_prerequisite";

  var _cacheDom = function() {
    $btnDelete        = $("#btn-delete");
    $btnConfirmDelete = $("#btn-confirm-delete");
    $modalDelete      = $("#modal-delete");

    $btnPrerequisite        = $("#btn-prerequisite");
    $btnConfirmPrerequisite = $("#btn-confirm-prerequisite");
    $modalPrerequisite      = $("#modal-prerequisite");
    $selectLoanProduct      = $("#select-loan-product");

    templateErrorList = $("#template-error-list").html();

    $message  = $(".message");
  };

  var _bindEvents = function() {
    $btnPrerequisite.on("click", function() {
      $modalPrerequisite.modal("show");
      $message.html("");
    });

    $btnConfirmPrerequisite.on("click", function() {
      $btnConfirmPrerequisite.prop("disabled", true);

      var loanProductId = $selectLoanProduct.val();

      $.ajax({
        url: _urlModifyPrerequisite,
        method: 'POST',
        dataType: 'json',
        data: {
          id: id,
          loan_product_id: loanProductId,
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

            $btnConfirmPrerequisite.prop("disabled", false);
          }
        }
      });
    });

    $btnDelete.on("click", function() {
      $modalDelete.modal("show");
      $message.html("");
    });

    $btnConfirmDelete.on("click", function() {
      $btnConfirmDelete.prop("disabled", true);

      $.ajax({
        url: _urlDelete,
        method: 'POST',
        dataType: 'json',
        data: {
          id: id,
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

            $btnConfirmDelete.prop("disabled", false);
          }
        }
      });
    });
  };

  var init  = function(options) {
    id                = options.id;
    authenticityToken = options.authenticityToken;

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
