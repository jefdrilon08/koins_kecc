//= require_directory ./lib

CicReport = (function() {
  var $providerCode      = $("#provider-code");
  var $downloadBtn       = $("#download-btn");
  var $startDate         = $("#start-date");
  var $endDate           = $("#end-date");

  var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      data = {
        start_date: $startDate.val(),
        end_date: $endDate.val(),
        provider_code: $providerCode.val(),
      };

      window.location = "/reports/cic_reports?" + encodeQueryData(data);
      //window.location = "/reports/cic_report?" + encodeQueryData(data);
    });
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
