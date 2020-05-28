import 'datatables.net';
//import 'datatables.net/css/jquery.dataTables.css';

var Index = (function() {
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
