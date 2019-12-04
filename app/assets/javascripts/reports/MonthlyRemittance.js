//= require_directory ./lib

MonthlyRemittance = (function() {
  var $btnExcel          = $("#btn-excel");
  var $filterStartDate   = $("#filter-start-date");
  var $filterEndDate     = $("#filter-end-date");
  var $branchSelect      = $("#branch-select");

  var encodeQueryData = function(data) {
    var ret = []
    for(var d in data) {
      ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
    }

    return ret.join("&");
  };

  var _bindEvents = function() {
    $btnExcel.on('click', function() {
      data = {
        branch_id: $branchSelect.val(),
        start_date: $filterStartDate.val(),
        end_date: $filterEndDate.val()
      };

      window.location = "/reports/download_excel_monthly_remittance?" + encodeQueryData(data);
    });    
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
