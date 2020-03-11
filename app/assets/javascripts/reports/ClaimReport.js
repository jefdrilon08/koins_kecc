//= require_directory ./lib

ClaimReport = (function() {
  var $downloadBtn       = $("#download-btn");
  var $startDate         = $("#start-date");
  var $endDate           = $("#end-date");
  var $branchSelect      = $("#branch-select");
  var $typeOfClaim       = $("#type-of-claims");
 
  var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      data = {
        claim_type: $typeOfClaim.val(),
        start_date: $startDate.val(),
        end_date: $endDate.val(),
        branch: $branchSelect.val(),
      };

      window.location = "/reports/claim_generate_report?" + encodeQueryData(data);
    });
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
