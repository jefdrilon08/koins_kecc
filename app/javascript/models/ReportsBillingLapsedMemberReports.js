import $ from "jquery";

var $btnExcel;
var $CollectionDateFrom;
var CollectionDateTo;
var status;
var $branchSelect;

var _cacheDom = function() {
  $btnExcel          = $("#btn-excel");
  $branchSelect      = $("#branch-select");
  $CollectionDateFrom  = $("#collection-date-from");
  CollectionDateTo    = $("#collection-date-to");
  $status            = $("#status");
}

var encodeQueryData = function(data) {
  var ret = []
  for(var d in data) {
    ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
  }

  return ret.join("&");
};

var _bindEvents = function() {
  $btnExcel.on('click', function() {
    var data = {
      branch_id: $branchSelect.val(),
      collection_date_from: $CollectionDateFrom.val(),
      collection_date_to: CollectionDateTo.val(),
      status: $status.val()
    };

    window.location = "/reports/billing_lapsed_member_reports_excel?" + encodeQueryData(data);
  });    
};

var init = function() {
  _cacheDom();
  _bindEvents();
};

export default { init: init };
