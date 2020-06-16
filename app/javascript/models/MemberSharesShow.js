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

    var id    = $(this).data("id");
    var type  = "member_share";

    $modalPrint.modal("hide");
    window.open("/print?type=" + type + "&id=" + id);
  });
};

var init  = function(options) {
  authenticityToken = options.authenticityToken;

  _cacheDom();
  _bindEvents();
};

export default { init: init };
