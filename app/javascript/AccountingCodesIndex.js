import 'datatables.net';

var AccountingCodesIndex = (function() {
  var $dataTable;

  var init  = function() {
    _cacheDom();
    _bindEvents();
  };

  var _cacheDom = function() {
    $dataTable  = $("#data-table");
  };

  var _bindEvents = function() {
    $dataTable.DataTable({
      fixedHeader: true
    });
  };

  return {
    init: init
  };
})();

export default AccountingCodesIndex;
