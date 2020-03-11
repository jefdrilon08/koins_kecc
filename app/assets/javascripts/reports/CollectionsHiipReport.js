//= require_directory ./lib

CollectionsHiipReport = (function() {
  var $downloadBtn       = $("#download-btn");
  var $startDate         = $("#start-date");
  var $endDate           = $("#end-date");
  var $branchSelect      = $("#branch-select");
  var _authenticityToken;

  var encodeQueryData = function(data) {
    var ret = []
    for(var d in data) {
      ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
    }

    return ret.join("&");
  };
  
   var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      data = {
        start_date: $startDate.val(),
        end_date: $endDate.val(),
        branch: $branchSelect.val(),
      };

      window.location = "/reports/collections_hiip_reports?" + encodeQueryData(data);
    });

    
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
