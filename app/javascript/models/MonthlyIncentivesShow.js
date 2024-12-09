import Mustache from "mustache";
import $ from "jquery";

var $modalPrint;
var $printMessage;
var $btnPrintPdf;
var $btnDownloadExcel;


var $btnPrint;
var loader;

var id;
var templateErrorList;
var authenticityToken;

var _urlDownload= "/data_stores/monthly_incentives_excel/";

var $message;

var _cacheDom = function() {

  $btnPrint         = $("#btn-print");
  $printMessage       = $(".print-message");
  $btnPrintPdf      =  $("#btn-print-pdf");
  $btnDownloadExcel =  $("#btn-dl-excel")

  $modalPrint         = $("#modal-print");


  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
  loader            = $("#template-loader").html();
};

var _bindEvents = function() {

  
 $btnPrintPdf.on("click", function() {
    var print_mi = $btnPrintPdf.data('id');

    $modalPrint.show();
    $printMessage.html(
      Mustache.render(
        loader,
        {}
      )
    );

    $modalPrint.hide();
    window.open("/print?id=" + print_mi + "&type=print_monthly_incentives");
  });

  $btnDownloadExcel.on("click", function() {
    console.log("hello");
    // $.ajax({
    //   url: _urlDownload+$btnDownloadExcel.data('id'),
    //   method: 'GET',
    //   success: function(response) {
    //     console.log(response);
    //     console.log("kkkk");

    //     var filename = response.filename;

    //     window.location.href = "/download_file?filename=" + filename;
    //   },
    //   error: function(response) {
    //     console.log(response);
    //     alert("Something went wrong when fetching data store");
    //   }
    // });
    window.open(_urlDownload+$btnDownloadExcel.data('id'));
  });

  

};

var init  = function(options) {
  id                = options.id;
  authenticityToken = options.authenticityToken;

  _cacheDom();
  _bindEvents();
};

export default { init: init }
