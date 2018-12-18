var Index = (function() {
  var $btnNew;
  var $modalNew;

  var $message;
  var templateErrorList;

  var _cacheDom = function() {
    $btnNew   = $("#btn-new");
    $modalNew = $("#modal-new");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  }

  var _bindEvents = function() {
    $btnNew.on("click", function() {
      $modalNew.modal("show");
    });
  }

  var init  = function() {
    _cacheDom();
    _bindEvents();
  }

  return  {
    init: init
  }
})();
