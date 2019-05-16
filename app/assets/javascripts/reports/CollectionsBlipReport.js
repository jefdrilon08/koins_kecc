//= require_directory ./lib

CollectionsBlipReport = (function() {
  var $downloadBtn       = $("#download-btn");
  var $startDate         = $("#start-date");
  var $endDate           = $("#end-date");
  var $brachSelect       = $("#branch-select");

  var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      data = {
        start_date: $startDate.val(),
        end_date: $endDate.val(),
        branch: $brachSelect.val(),
      };

      window.location = "/reports/collections_blip_reports?" + encodeQueryData(data);
    });
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
