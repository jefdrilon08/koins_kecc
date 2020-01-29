var Index = (function() {
  var $btnNewTransaction;
  var $modalNewTransaction;
  var $selectBranch;
  var $inputCollectionDate;

  var _options;

  var _cacheDom = function() {
    $btnNewTransaction    = $("#btn-new-transaction");
    $modalNewTransaction  = $("#modal-new-transaction");
    $selectBranch         = $("#select-branch");
    $inputCollectionDate  = $("#input-collection-date");
  };

  var _bindEvents = function() {
    $btnNewTransaction.on("click", function() {
      $modalNewTransaction.modal("show");
    });
  };

  var init  = function(options) {
    _options  = options;

    _cacheDom();
    _bindEvents();
  };
  return {
    init: init
  };
})();
