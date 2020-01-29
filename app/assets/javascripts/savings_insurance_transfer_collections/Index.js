var Index = (function() {
  var $btnNewTransaction;
  var $modalNewTransaction;
  var $selectBranch;
  var $selectCenter;
  var $inputCollectionDate;

  var _options;
  var _authenticityToken;

  var _cacheDom = function() {
    $btnNewTransaction    = $("#btn-new-transaction");
    $modalNewTransaction  = $("#modal-new-transaction");
    $selectBranch         = $("#select-branch");
    $selectCenter         = $("#select-center");
    $inputCollectionDate  = $("#input-collection-date");
  };

  var _bindEvents = function() {
    $btnNewTransaction.on("click", function() {
      $modalNewTransaction.modal("show");
    });
  };

  var init  = function(options) {
    _options            = options;
    _authenticityToken  = _options.authenticityToken;

    _cacheDom();
    _bindEvents();
  };
  return {
    init: init
  };
})();
