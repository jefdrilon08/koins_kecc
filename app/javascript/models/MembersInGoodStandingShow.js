import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";
var $modalPrint;
var $printMessage;
var $btnPrintPdf;


var $btnPrint;
var loader;

var id;
var templateErrorList;
var authenticityToken;

var $message;

var _cacheDom = function() {

  $btnPrint         = $("#btn-print");
  $printMessage     = $(".print-message");
  $btnPrintPdf      = $("#btn-print-pdf");
  $btnExcel         = $("#btn-excel");
  $modalPrint       = $("#modal-print");
  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
  loader            = $("#template-loader").html();
};

var _bindEvents = function() {

  
 $btnPrintPdf.on("click", function() {
    var print_icpr = $btnPrintPdf.data('id');

    $modalPrint.show();
    // $printMessage.html(
    //  Mustache.render(
    //    loader,
    //    {}
    //  )
    // );
    $modalPrint.hide();
    window.open("/print?id=" + print_icpr + "&type=print_migs");
  });

  $btnExcel.on("click", function () {

    id = $(this).data("id");	
    if (!id) {
      console.error("Missing ID for Excel download");
      $message.html("Error: Missing ID.");
      return;
    }else{
      console.log(id);
    }
    
    $.ajax({
      url: "/data_stores/members_in_good_standing/" + id + "/excel",
      method: "GET",
      data: {
        id: id,
        authenticity_token: authenticityToken,
      },
      dataType: "json",
      success: function (response) {
        console.log(response);
        window.open(response.download_url, "_blank");
      },
      error: function (response) {
        $message.html("Error downloading Excel.");
      },
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
