var memberQuarterlyReports = (function() {
  var $searchBtn;
  var $downloadBtn;
  var $memberReportsSection;
  var $memberReportsTemplate;
  var accountClass;
  var $data;
  var $startDate        = $("#start-date");
  var $endDate          = $("#end-date");
  var memberQuarterlyReportsUrl  = "/api/v1/reports/member_quarterly_reports";

  var _cacheDom = function() {
    $searchBtn = $("#search-btn");
    $downloadBtn = $("#download-btn");
    $memberQuarterlyReportsSection = $("#member-quarterly-reports-section");
    $memberQuarterlyReportsTemplate = $("#member-quarterly-reports-template").html();
  }

  var _loadDefaults = function() {
  }

  var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      $downloadBtn.addClass('loading');

      var startDate  = $startDate.val();
      var endDate = $endDate.val();

      var params = {
        start_date: startDate,
        end_date: endDate
      };

      $.ajax({
        url: memberQuarterlyReportsUrl,
        method: 'GET',
        dataType: 'json',
        data: params,
        success: function(data) {
          console.log(data);
          $memberQuarterlyReportsSection.html(Mustache.render($memberQuarterlyReportsTemplate, data));
          
          $downloadBtn.removeClass('loading');

          tempUrl = data.download_url;
          window.open(tempUrl, '_blank');

          // Make sticky
          $(".sticky").stickyTableHeaders();
        },
        error: function(data) {
          toastr.error("Error in generating report for members");
          $downloadBtn.removeClass('loading');
        }
      });
    });

    $searchBtn.on('click', function() {
      $searchBtn.addClass('loading');  
      
      var startDate  = $startDate.val();
      var endDate = $endDate.val();

      var params = {
        start_date: startDate,
        end_date: endDate
      };

      $.ajax({
        url: memberQuarterlyReportsUrl,
        method: 'GET',
        dataType: 'json',
        data: params,
        success: function(data) {
          console.log(data);
          $memberQuarterlyReportsSection.html(Mustache.render($memberQuarterlyReportsTemplate, data));

          $memberQuarterlyReportsSection.find(".curr").each(function() {
            $(this).html(numberWithCommas($(this).html()));
          });

          toastr.info("Generating quarterly report for members");
          $searchBtn.removeClass('loading');

          // Make sticky
          $(".sticky").stickyTableHeaders();
        },
        error: function(data) {
          toastr.error("Error in generating quarterly report for members");
          $searchBtn.removeClass('loading');
        }
      });
    });
  }

  var init = function() {
    _cacheDom();
    _loadDefaults();
    _bindEvents();
  }

  return {
    init: init
  };
})();

$(document).ready(function() {
  memberQuarterlyReports.init();
});
