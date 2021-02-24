import Mustache from "mustache/mustache";
import "select2/dist/js/select2.min";
import "chart.js/dist/Chart.min.js";

var $btnSync;
var $selectYear;
var $selectBranches;
var $selectAccountingCode;
var $xFormControl;

var $message;
var templateErrorList;
var templateSuccessMessage;

var _urlSync;
var _userId;
var _xKoinsAppAuthSecret;

var ctxAccountingBalance;
var chartAccountingBalance;

var _cacheDom = function() {
  $btnSync              = $("#btn-sync");
  $selectYear           = $("#select-year");
  $selectBranches       = $("#select-branches");
  $selectAccountingCode = $("#select-accounting-code");
  $xFormControl         = $(".x-form-control");

  $message                = $(".message");
  templateErrorList       = $("#template-error-list").html();
  templateSuccessMessage  = $("#template-success-message").html();

  ctxAccountingBalance  = document.getElementById('chart-accounting-balance').getContext('2d');
};

var _clearCharts = function() {
  chartAccountingBalance.data.datasets = [];

  chartAccountingBalance.update();
};

var _updateData = function(data) {
  data.forEach(function(d) {
    // Additional options for line
    d.backgroundColor = d.color;
    d.lineTension     = 0;

    chartAccountingBalance.data.datasets.push(d);
  });

  chartAccountingBalance.update();
}

var _bindEvents = function() {
  chartAccountingBalance  = new Chart(ctxAccountingBalance, {
                              type: 'line',
                              data: {
                                labels: [
                                  'January',
                                  'February',
                                  'March',
                                  'April',
                                  'May',
                                  'June',
                                  'July',
                                  'August',
                                  'September',
                                  'October',
                                  'November',
                                  'December'
                                ],
                                datasets: []
                              },
                              options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                scales: {
                                  yAxes: [{
                                    ticks: {
                                      beginAtZero: true,
                                      userCallback: function(value, index, values) {
                                        return value.toLocaleString();
                                      }
                                    }
                                  }]
                                }
                              }
                            });

  $selectBranches.select2();

  $btnSync.on("click", function() {
    var branchIds         = $selectBranches.val();
    var accountingCodeId  = $selectAccountingCode.val();
    var year              = $selectYear.val();

    var data = {
      branch_ids:         branchIds,
      accounting_code_id: accountingCodeId,
      year:               year,
      user_id:            _userId
    }

    $xFormControl.prop("disabled", true);
    $message.html("Loading...");

    _clearCharts();

    $.ajax({
      url: _urlSync,
      method: 'GET',
      headers: {
        'X-KOINS-APP-AUTH-SECRET': _xKoinsAppAuthSecret,
        'Access-Control-Allow-Methods': '*',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': 'true'
      },
      data: data,
      success: function(response) {
        console.log(response);

        $message.html(
          Mustache.render(
            templateSuccessMessage,
            { message: "Success! Data generated!" }
          )
        );

        $xFormControl.prop("disabled", false);

        _updateData(response.data);
      },
      error: function(response) {
        console.log(response.responseText);
        var errors  = [];

        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          console.log(err);
          errors  = ["Something went wrong"];
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $xFormControl.prop("disabled", false);
        }
      }
    });
  });
};

var init = function(options) {
  _urlSync              = options.urlSync;
  _userId               = options.userId;
  _xKoinsAppAuthSecret  = options.xKoinsAppAuthSecret;

  _cacheDom();
  _bindEvents();
};

export default { init: init };
