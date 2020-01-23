var Index  = (function() {
  var authenticityToken;

  var $modalNew;
  var $btnNew;
  var $btnConfirmNew;

  var $selectYear;
  var $selectBranch;

  var $message;
  var templateErrorList;

  var _cacheDom = function() {
    $modalNew         = $("#modal-new");
    $btnNew           = $("#btn-new");
    $btnConfirmNew    = $("#btn-confirm-new");
    $selectYear       = $("#select-year");
    $selectBranch     = $("#select-branch");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  }

  var _bindEvents = function() {
  }

  var init  = function(config) {
    id                = config.id;
    authenticityToken = config.authenticityToken;

    _cacheDom();
    _bindEvents();
  }

  return {
    init: init
  }
})();

