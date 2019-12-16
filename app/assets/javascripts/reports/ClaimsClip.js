//= require_directory ./lib

ClaimsClip = (function() {
  var $downloadBtn              = $("#excel-btn");
  var $typeOfLoan               = $("#type-of-loan");
  var $brachSelect              = $("#branch-select");
  var $startDate                = $("#start-date");
  var $endDate                  = $("#end-date");

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
        type_of_loan: $typeOfLoan.val(),
        branch: $brachSelect.val(),
        start_date: $startDate.val(),
        end_date: $endDate.val()
      };

      window.location = "/reports/claims_clip_report?" + encodeQueryData(data);
    });
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
