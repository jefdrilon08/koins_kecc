import Mustache from "mustache/mustache";

var _id;
var _authenticityToken;

var $modalProcess;
var $btnProcess;
var $btnConfirmProcess;
var $message;
var templateErrorList;
var templateCenterOptions;
var $selectBranch;
var $selectCenter;
var _centers = [];

var _cacheDom = function() {
  $modalProcess         = $("#modal-process");
  $btnProcess           = $("#btn-process");
  $btnConfirmProcess    = $("#btn-confirm-process");
  $selectBranch         = $("#select-branch");
  $selectCenter         = $("#select-center");
  $message              = $(".message");
  templateErrorList     = $("#template-error-list").html();
  templateCenterOptions = $("#template-center-options").html();
}

var _bindEvents = function() {
  $btnProcess.on("click", function() {
    $modalProcess.modal("show");
  });

  $selectBranch.on("change", function() {
    var branchId = $(this).val();

    if(branchId) {
      $.ajax({
        url: "/api/v1/branches/fetch_centers",
        data: {
          id: branchId
        },
        success: function(response) {
          $selectCenter.html(
            Mustache.render(
              templateCenterOptions,
              response
            )
          )
        },
        error: function(response) {
          alert("Cannot fetch centers");
        }
      });
    }
  });
}

var init = function(options) {
  _id                 = options.id;
  _authenticityToken  = options.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
