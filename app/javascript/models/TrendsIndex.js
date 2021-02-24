import Mustache from "mustache/mustache";
import "select2/dist/js/select2.min";

var $btnSync;
var $selectYear;
var $selectBranches;
var $xFormControl;

var $message;
var templateErrorList;
var templateSuccessMessage;

var _urlSync;
var _userId;
var _xKoinsAppAuthSecret;

var _cacheDom = function() {
  $btnSync        = $("#btn-sync");
  $selectYear     = $("#select-year");
  $selectBranches = $("#select-branches");
  $xFormControl   = $(".x-form-control");

  $message                = $(".message");
  templateErrorList       = $("#template-error-list").html();
  templateSuccessMessage  = $("#template-success-message").html();
};

var _bindEvents = function() {
  $selectBranches.select2();

  $btnSync.on("click", function() {
    $xFormControl.prop("disabled", true);
    $message.html("Loading...");
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
