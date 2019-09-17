var hiipClaimsIndex = (function() {
  var branchId;
  var $branchSelect;

  var $clickableRow; 

  var _cacheDom = function() {
    $clickableRow  = $(".clickable");
  }

  var _bindEvents = function() {
    $clickableRow.on('click', function() {
      var clipClaimId = $(this).data('hiip-claim-id');
      window.location = "/hiip_claims/" + hiipClaimId;
    });

  }

  var init = function() {
    _cacheDom();
    _bindEvents();
  }

  return {
    init: init
  };
})();

$(document).ready(function() {
  console.log($('#center-select').val());

  /*
   * Get members based on selected center
   */
  $('#modal-branch-select').on('change', function() {
    var branchSelect = $(this);
    var centerSelect = $("#modal-center-select");
    $.ajax({
      url: '/api/v1/utils/centers' ,
      type: 'GET',
      dataType: 'json',
      data: { branch_id: branchSelect.val() },
      success: function(response) {
        var centers = response.data.centers;
        populateSelect(centerSelect, centers, 'id', 'name');
      },
      error: function() {
        toastr.error('Error in loading centers');
      }
    });
  });

  $('#modal-center-select').on('change', function() {
    var centerSelect = $(this);
    var memberSelect = $('#modal-member-select');
    var centerId = $(this).val();  
    var url = "/api/v1/get_members?center_id=" + centerId;

    $.ajax({
      url: url,
      type: 'GET',
      success: function(response) {
        console.log(response);
        populateSelect(memberSelect, response.data.members, 'id', 'name');
      },
      error: function() {
        toastr.error('Error in loading members');
      }
    });
  });

  hiipClaimsIndex.init();
});
