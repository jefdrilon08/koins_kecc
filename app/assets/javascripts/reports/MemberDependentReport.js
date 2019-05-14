//= require_directory ./lib

MemberDependentReport = (function() {
  var $downloadBtn       = $("#download-btn");
  var $startDate         = $("#start-date");
  var $endDate           = $("#end-date");
  var $branchSelect      = $("#branch-select")

  var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      data = {
        end_date: $endDate.val(),
        start_date: $startDate.val(),
        branch: $branchSelect.val(),
      };

      window.location = "/reports/member_dependent_reports?" + encodeQueryData(data);
    });
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };s
})();
