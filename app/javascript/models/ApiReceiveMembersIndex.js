import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var $btnNewTransaction;
var $btnClick;
var $btnConfirmNewTransaction;
var $modalNewTransaction;

var $selectBranch;
var $inputCollectionDate;

var $message;

var templateErrorList;

var branches  = [];

var urlBranches                               = "/api/v1/branches";
var urlCreateInsuranceFundTransferCollection  = "/api/v1/insurance_fund_transfer_collections";

var _authenticityToken;

var _cacheDom = function() {
  $btnClick                         = $("#btn-click")
  $selectBranch                     = $("#select-branch");
  $inputCollectionDate              = $("#input-collection-date");
  $message                          = $(".message");
  templateErrorList                 = $("#template-error-list").html();

};

var _bindEvents = function() {
  $btnClick.on("click", function() {
    console.log("click!"); // Use console.log instead of alert.log
  });

};

var init  = function(config) {
  _authenticityToken  = config.authenticityToken;

  $.ajax({
    url: urlBranches,
    method: 'GET',
    success: function(response) {
      branches  = response.branches;
    },
    error: function(response) {
      console.log(response);
      alert("Error in fetching branches");
    }
  });

  _cacheDom();
  _bindEvents();
};

export default { init: init };
