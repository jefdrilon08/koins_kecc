var Index = (function() {
  var $btnNewTransaction;
  var $btnConfirmNewTransaction;
  var $modalNewTransaction;

  var $selectBranch;
  var $selectCenter;
  var $selectMember;

  var $message;

  var templateErrorList;

  var branches  = [];
  var centers   = [];
  var members   = [];
 
  var $parameters               = $("#parameters");
  var memberId                  = $parameters.data('member-id');

  var urlBranches       = "/api/v1/branches";
  var urlCenters       = "/api/v1/centers";
  var urlMembers      ="/api/v1/members";

  var _authenticityToken;

  var _cacheDom = function() {
    $btnNewTransaction        = $("#btn-new-transaction");
    $btnConfirmNewTransaction = $("#btn-confirm-new-transaction");
    $modalNewTransaction      = $("#modal-new-transaction");

    $selectBranch         = $("#select-branch");
    $selectCenter         = $("#select-center");
    $selectMember          = $("#select-member")

    $message  = $(".message");

    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnNewTransaction.on("click", function() {
      $modalNewTransaction.modal("show");
    });

    $btnConfirmNewTransaction.on("click", function() {
      var branchId        = $selectBranch.val();
      var centerId        = $selectCenter.val();
      var memberId        = $selectMember.val();

      $message.html(
        "Loading..."
      );

      $btnConfirmNewTransaction.prop("disabled", true);
      $selectBranch.prop("disabled", true);
      $selectCenter.prop("disabled", true);
      $selectMember.prop("disabled", true)

    });

    $selectBranch.on("change", function() {
      var branchId  = $(this).val();

      $selectCenter.html("");
      $selectCenter.append("<option>--ALL--</option>")
      for(var i = 0; i < branches.length; i++) {
        if(branches[i].id == branchId) {
          for(var j = 0; j < branches[i].centers.length; j++) {
            $selectCenter.append(
              "<option value='" + branches[i].centers[j].id + "'>" + branches[i].centers[j].name + "</option>"
            );
          }
        }
      }
    });

    $selectCenter.on("change", function() {
      var centerId  = $(this).val();

      $selectMember.html("");
      $selectMember.append("<option>--ALL--</option>")
      for(var i = 0; i < centers.length; i++) {
        if(centers[i].id == centerId) {
          for(var j = 0; j < centers[i].members.length; j++) { 
            $selectMember.append(
              "<option value='" + centers[i].members[j].id + "'>" + centers[i].members[j].name + "</option>"
            );
          }
        }
      }
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

    $.ajax({
      url: urlCenters,
      method: 'GET',
      success: function(response) {
        centers  = response.centers;
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching centers");
      }
    });

    $.ajax({
      url: urlMembers,
      method: 'GET',
      success: function(response) {
        members  = response.members;
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching members");
      }
    });

    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
