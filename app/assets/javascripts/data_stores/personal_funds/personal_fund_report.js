var Exports = {
};

PersonalFundReport = (function() {
  var $officerId         = $("#office-id");
  var $downloadBtn       = $("#download-btn");
  var $centerId          = $("#center-id");


  var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      data = {
        officer_id: $officerId.val(),
        center_id: $centerId.val(),

      };

      window.location = "/data_stores/personal_funds/personal_fund_reports?" + encodeQueryData(data);

    });
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
