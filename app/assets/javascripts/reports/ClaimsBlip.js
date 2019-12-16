//= require_directory ./lib

ClaimsBlip = (function() {
  var $downloadBtn                        = $("#excel-btn");
  var $categoryOfCauseOfDeathTpdAccident  = $("#category-of-cause-of-death-tpd-accident");
  var $classificationOfInsured            = $("#classification-of-insured");
  var $typeOfInsurancePolicy              = $("#type-of-insurance-policy");
  var $brachSelect                        = $("#branch-select");
  var $startDate                          = $("#start-date");
  var $endDate                            = $("#end-date");

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
        category_of_cause_of_death_tpd_accident: $categoryOfCauseOfDeathTpdAccident.val(),
        classification_of_insured: $classificationOfInsured.val(),
        type_of_insurance_policy: $typeOfInsurancePolicy.val(),
        start_date: $startDate.val(),
        end_date: $endDate.val(),
        branch: $brachSelect.val(),
      };

      window.location = "/reports/claims_blip_report?" + encodeQueryData(data);
    });
  };

  var init = function() {
    _bindEvents();
  };

  return {
    init: init
  };
})();
