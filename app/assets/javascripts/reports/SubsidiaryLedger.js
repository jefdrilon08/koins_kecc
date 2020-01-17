//= require_directory ./lib

SubsidiaryLedger = (function() {
  var $branch           = $("#branch-select");
  var $downloadBtn      = $("#download-btn");
  var $asOf             = $("#as-of");

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
        as_of: $asOf.val(),
        branch: $branch.val(),
      };

      window.location = "/reports/subsidiary_ledger_report?" + encodeQueryData(data);
    });
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
