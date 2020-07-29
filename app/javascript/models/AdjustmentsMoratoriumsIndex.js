import Mustache from "mustache/mustache";

var $modalNew;
var $modalDelete;
var $modalProcess;
var $selectBranch;
var $selectCenter;
var $selectMember;
var $inputDateInitialized;
var $inputNumberOfDays;
var $btnNew;
var $btnDelete;
var $btnProcess;
var $btnConfirmNew;
var $btnConfirmDelete;
var $btnConfirmProcess;
var $message;
var templateErrorList;
var _authenticityToken;

var _centers  = [];
var _members  = [];

var _branchId;
var _centerId;
var _memberId;
var _moratoriumId;

var init  = function(options) {
  _authenticityToken = options.authenticityToken;

  _cacheDom();
  _bindEvents();
};

var _urlCreate  = "/api/v1/adjustments/moratoriums/create";
var _urlDelete  = "/api/v1/adjustments/moratoriums/delete";
var _urlProcess = "/api/v1/adjustments/moratoriums/process";
var _urlCenters = "/api/v1/branches/fetch_centers";

var _cacheDom = function() {
  $modalNew             = $("#modal-new");
  $modalDelete          = $("#modal-delete");
  $modalProcess         = $("#modal-process");
  $selectBranch         = $("#select-branch");
  $selectCenter         = $("#select-center");
  $selectMember         = $("#select-member");
  $inputDateInitialized = $("#input-date-initialized");
  $inputNumberOfDays    = $("#input-number-of-days");
  $btnNew               = $("#btn-new");
  $btnDelete            = $(".btn-delete");
  $btnProcess           = $(".btn-process");
  $btnConfirmNew        = $("#btn-confirm-new");
  $btnConfirmDelete     = $("#btn-confirm-delete");
  $btnConfirmProcess    = $("#btn-confirm-process");
  $message              = $(".message");

  templateErrorList = $("#template-error-list").html();
};

var _loadCenterOptions  = function() {
  $selectCenter.html("");
  $selectMember.html("");

  if(_centers.length > 0) {
    _centerId = _centers[0].id;

    for(var i = 0; i < _centers.length; i++) {
      $selectCenter.append(new Option(_centers[i].name, _centers[i].id));
    }
  }

  if(_members.length > 0) {
    _memberId = _members[0].id;

    for(var i = 0; i < _members.length; i++) {
      $selectMember.append(new Option(_members[i].full_name, _members[i].id));
    }

    $selectMember.val(_memberId);
  }
};

var _bindEvents = function() {
  $btnProcess.on("click", function() {
    _moratoriumId = $(this).data("id");
    $modalProcess.modal("show");
  });

  $btnConfirmProcess.on("click", function() {
    $message.html("Loading...");
    $btnConfirmProcess.prop("disabled", true);

    $.ajax({
      url: _urlProcess,
      method: "POST",
      data: {
        id: _moratoriumId
      },
      success: function(response) {
        $message.html("Success!");
        window.location.reload();
      },
      error: function(response) {
        var errors  = [];

        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          errors = ["Something went wrong"];
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $btnConfirmProcess.prop("disabled", false);
        }
      }
    });
  });

  $btnDelete.on("click", function() {
    _moratoriumId = $(this).data("id");
    $modalDelete.modal("show");
  });

  $btnConfirmDelete.on("click", function() {
    $message.html("Loading...");
    $btnConfirmDelete.prop("disabled", true);

    $.ajax({
      url: _urlDelete,
      method: "POST",
      data: {
        id: _moratoriumId
      },
      success: function(response) {
        $message.html("Success!");
        window.location.reload();
      },
      error: function(response) {
        console.log(response);
        alert("Error in deleting record!");
        $message.html("");
        $btnConfirmDelete.prop("disabled", false);
      }
    });
  });

  $selectCenter.on("change", function() {
    _centerId = $selectCenter.val();

    _members  = _centers.find(c => c.id === _centerId).members;

    $selectMember.html("");
    for(var i = 0; i < _members.length; i++) {
      $selectMember.append(new Option(_members[i].full_name, _members[i].id));
    }
  });

  $selectBranch.on("change", function() {
    $.ajax({
      method: 'GET',
      url: _urlCenters,
      data: {
        id: $selectBranch.val(),
        with_members: true
      },
      success: function(response) {
        _centers  = response.centers;

        if(_centers.length > 0) {
          _members  = _centers[0].members;
        }

        _loadCenterOptions();
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching centers");
      }
    });
  });

  $btnNew.on("click", function() {
    $modalNew.modal("show");
  });

  $btnConfirmNew.on("click", function() {
    _branchId           = $selectBranch.val();
    _centerId           = $selectCenter.val();
    _memberId           = $selectMember.val();
    var dateInitialized = $inputDateInitialized.val();
    var numberOfDays    = $inputNumberOfDays.val();

    $btnConfirmNew.prop("disabled", true);
    $selectBranch.prop("disabled", true);
    $selectCenter.prop("disabled", true);
    $selectMember.prop("disabled", true);
    $inputDateInitialized.prop("disabled", true);
    $inputNumberOfDays.prop("disabled", true);

    $message.html("Loading...");

    $.ajax({
      url: _urlCreate,
      method: "POST",
      data: {
        branch_id: _branchId,
        center_id: _centerId,
        member_id: _memberId,
        date_initialized: dateInitialized,
        number_of_days: numberOfDays,
        authenticity_token: _authenticityToken
      },
      success: function(resonse) {
        $message.html(
          "Success! Redirecting..."
        );

        window.location.reload();
      },
      error: function(response) {
        var errors  = [];

        try {
          errors  = JSON.parse(response.responseText).full_messages;
        } catch(err) {
          errors = ["Something went wrong"];
        } finally {
          $message.html(
            Mustache.render(
              templateErrorList,
              { errors: errors }
            )
          );

          $btnConfirmNew.prop("disabled", false);
          $selectBranch.prop("disabled", false);
          $selectCenter.prop("disabled", false);
          $selectMember.prop("disabled", false);
          $inputDateInitialized.prop("disabled", false);
          $inputNumberOfDays.prop("disabled", false);
        }
      }
    });
  });
};

export default { init: init };
