//= require_directory ./lib

InsuredLoans = (function() {
  var $btnPrint          = $("#btn-print");
  var $btnDownloadCsv    = $("#btn-download-csv") 
  var $filterStartDate   = $("#filter-start-date");
  var $filterEndDate     = $("#filter-end-date");
  var $filterLoanStatus  = $("#filter-loan-status");
  var $branchSelect      = $("#branch-select");

  var _bindEvents = function() {
    $btnPrint.on('click', function() {
      data = {
        start_date: $filterStartDate.val(),
        end_date: $filterEndDate.val(),
         branch_id: $branchSelect.val(),
        loan_status: $filterLoanStatus.val(),
      };

      window.location = "/reports/print_insured_loans?" + encodeQueryData(data);
    });

    $btnDownloadCsv.on('click', function() {
      data = {
        start_date: $filterStartDate.val(),
        end_date: $filterEndDate.val(),
         branch_id: $branchSelect.val(),
        loan_status: $filterLoanStatus.val(),
      };

      window.location = "/reports/download_csv_insured_loans?" + encodeQueryData(data);
    });    
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
