import Mustache from "mustache/mustache";
var $modalPrint;
var $printMessage;
var $btnPrintPdf;


var $btnPrint;
var loader;

var id;
var templateErrorList;
var authenticityToken;
var $btnExcel;
var _urlDownload= "/data_stores/for_writeoff/excel";
var $message;

var _cacheDom = function() {

  $btnPrint           = $("#btn-print");
  $printMessage       = $(".print-message");
  $btnPrintPdf        = $("#btn-print-pdf");
  $btnExcel           = $("#btn-excel")
  $modalPrint         = $("#modal-print");


  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
  loader            = $("#template-loader").html();
};

var _bindEvents = function() {


  $btnExcel.on("click", function() {
    $.ajax({
      url: _urlDownload,
      method: 'GET',
      data: {
        id: id,
        authenticity_token: authenticityToken
      },
      dataType: 'json',
      success: function(response) {
        console.log(response);
        window.open(response.download_url, '_blank');
      },
      error: function(response) {
        $message.html("Error!");
      }
    });
  });


};





var init  = function(options) {
  id                = options.id;
  authenticityToken = options.authenticityToken;

  _cacheDom();
  _bindEvents();
};

export default { init: init }
