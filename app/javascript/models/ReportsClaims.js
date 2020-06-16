var $downloadBtn       = $("#download-btn");
var $startDate         = $("#start-date");
var $endDate           = $("#end-date");
var $branchSelect      = $("#branch-select");
var $typeOfClaim       = $("#type-of-claims");

var _cacheDom = function() {
  $downloadBtn       = $("#download-btn");
  $startDate         = $("#start-date");
  $endDate           = $("#end-date");
  $branchSelect      = $("#branch-select");
  $typeOfClaim       = $("#type-of-claims");
};

var encodeQueryData = function(data) {
  var ret = []
  for(var d in data) {
    ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
  }

  return ret.join("&");
};

var _bindEvents = function() {
  $downloadBtn.on('click', function() {
    var data = {
      claim_type: $typeOfClaim.val(),
      start_date: $startDate.val(),
      end_date: $endDate.val(),
      branch: $branchSelect.val(),
    };

    window.location = "/reports/claim_generate_report?" + encodeQueryData(data);
  });
};

var init = function() {
  _cacheDom();
  _bindEvents();
};

export default { init: init };
