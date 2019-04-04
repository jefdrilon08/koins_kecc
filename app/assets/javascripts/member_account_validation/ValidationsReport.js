var ValidationsReport = (function() {
  var $downloadBtn       = $("#download-btn");
  var $status            = $("#status");
  var $startDate         = $("#start-date");
  var $endDate           = $("#end-date");
  var $brachSelect       = $("#branch-select");
  var authenticityToken;

  var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      data = {
        authenticity_token: authenticityToken,
        status: $status.val(),
        start_date: $startDate.val(),
        end_date: $endDate.val(),
        branch: $brachSelect.val(),
      };

      window.location = "/pages/validations_report?" + encodeQueryData(data);
    });
  };

  var init = function(config) {
    authenticityToken  = config.authenticityToken;

    _bindEvents();
  };

  return {
    init: init
  };
})();
