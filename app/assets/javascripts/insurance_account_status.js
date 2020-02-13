var insuranceAccountStatus = (function() {
  var $downloadBtn        = $("#download-btn");
  var $branchSelect       = $("#branch-select");
  var $generateBtn        = $("#generate-btn");
  var insuranceAccountStatusReportUrl  = "/api/v1/pages/insurance_account_status_reports";
  var branch;
  var $insuranceAccountStatusReportTemplate;
  var $insuranceAccountStatusReportSection;

  var _cacheDom = function() {
    $generateBtn = $("#generate-btn");
    $downloadBtn = $("#download-btn");
    $insuranceAccountStatusReportTemplate = $("#insurance-account-status-report-template").html();
    $insuranceAccountStatusReportSection   = $("#insurance-account-status-report-section");
    $branchSelect = $("#branch-select");
  }

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
        branch: $branchSelect.val(),
      };

      window.location = "/pages/daily_report_insurance_account_status_excel?" + encodeQueryData(data);
    });

    $generateBtn.on('click', function() {
      $generateBtn.addClass('loading');

      branch = $branchSelect.val();
      var params = {
        branch: branch
      };
      $.ajax({
        url: insuranceAccountStatusReportUrl,
        method: 'GET',
        dataType: 'json',
        data: params,
        success: function(data) {
          console.log(data);
          $insuranceAccountStatusReportSection.html(Mustache.render($insuranceAccountStatusReportTemplate, data));

          $insuranceAccountStatusReportSection.find(".curr").each(function() {
            $(this).html(numberWithCommas($(this).html()));
          });

          toastr.info("Generating daily report insurance account status");
          $searchBtn.removeClass('loading');

          // Make sticky
          $(".sticky").stickyTableHeaders();
        },
        error: function(data) {
          toastr.error("Error in generating daily report insurance account status");
          $searchBtn.removeClass('loading');
        }
      });
    });
  };


  var init = function(config) {
    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
