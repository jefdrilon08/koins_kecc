import Mustache from "mustache/mustache";

var $btnPrint;
var $modalPrint;
var $message;

var authenticityToken;

var _cacheDom = function() {
  $btnPrint   = $("#btn-print");
  $modalPrint = $("#modal-print");

  $message  = $(".message");
};

var _bindEvents = function() {
  $btnPrint.on("click", function() {
    $modalPrint.modal("show");

    var id  = $(this).data("id");

    $.ajax({
      url: "/api/v1/print/generate_file",
      method: 'POST',
      data: { 
        id: id,
        type: "member_share",
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
};

var init  = function(options) {
  authenticityToken = options.authenticityToken;

  _cacheDom();
  _bindEvents();
};

export default { init: init };
