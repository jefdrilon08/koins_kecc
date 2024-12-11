import Mustache from "mustache";
import $ from "jquery";

var id;
var authenticityToken;

var $modalUpdate;
var $btnUpdate;
var $btnConfirmUpdate;

var $message;
var templateErrorList;

var _cacheDom = function() {
  $btnPrintPdf      = $("#print_loanstats")
  $btnDLExcel    = $("#excel_loanstats")
  $modalUpdate      = $("#modal-update");
  $btnUpdate        = $("#btn-update");
  $btnConfirmUpdate = $("#btn-confirm-update");

  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
  
}



var _bindEvents = function() {
  $btnUpdate.on("click", function() {
    $modalUpdate.show();
    $message.html("");
  });

  $btnConfirmUpdate.on("click", function() {
    $message.html("Loading...");
    $btnConfirmUpdate.prop("disabled", true);

    var data  = {
      id: id,
      authenticity_token: authenticityToken
    }

    $.ajax({
      url: "/api/v1/data_stores/branch_loans_stats/queue",
      method: 'POST',
      data: data,
      success: function(response) {
        $message.html("Success! Redirecting...");
        window.location.href="/data_stores/branch_loans_stats";
      },
      error: function(response) {
        $message.html("Something went wrong...");
        $btnConfirmUpdate.prop("disabled", false);
      }
    });
  });

    $btnPrintPdf.on("click", function() {
      var print_mi = $btnPrintPdf.data('id');
    console.log("test");
      window.open("/print?id=" + print_mi + "&type=print_loan_stats");
    });

    $btnDLExcel.on("click", function() {
      var print_mi = $btnDLExcel.data('id');
    console.log(print_mi);
        window.location = "/reports/loan_stats_excel?id=" + print_mi;
      }

      // window.open("/print?id=" + print_mi + "&type=print_loan_stats");
    );

}

var init  = function(config) {
  id                = config.id;
  authenticityToken = config.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
