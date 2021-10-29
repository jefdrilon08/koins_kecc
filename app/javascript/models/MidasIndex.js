import Mustache from "mustache/mustache";

var authenticityToken;

var $modalNew;
var $btnNew;
var $btnConfirmNew;
var $btnGenMidas;

var $selectBranch;
var $reportDate;
var $inputAsOf;

var $message;
var templateErrorList;

var _urlQueue;
var _userId;
var _xKoinsAppAuthSecret;
var _urlGenerate        = "/api/v1/midas/generate";


var _cacheDom = function() {
  $modalNew      = $("#modal-new");
  $btnNew        = $("#btn-new");
  $btnConfirmNew = $("#btn-confirm-new");
  $btnGenMidas   = $("#btn-gen-midas");

  $selectBranch = $("#select-branch");
  $reportDate	= $("#report-date");	
  $inputAsOf      = $("#input-as-of");

  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
}

var _bindEvents = function() {
  $btnNew.on("click", function() {
    $modalNew.modal("show");
    $message.html("");
  });

  $btnGenMidas.on("click", function() {
	  var branchId  = $selectBranch.val();
	  var reportDate = $reportDate.val();
	  //alert(_urlGenerate)
    $.ajax({
     url: _urlGenerate,
     method: "POST",
     data: {
	branchId: branchId,
	reportDate: reportDate
     },
    });
  });


}

var init  = function(config) {
  authenticityToken = config.authenticityToken;
  _urlQueue             = config.urlQueue;
  _userId               = config.userId;
  _xKoinsAppAuthSecret  = config.xKoinsAppAuthSecret;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
