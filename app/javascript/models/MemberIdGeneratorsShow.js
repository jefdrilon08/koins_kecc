import Mustache from "mustache/mustache";

var authenticityToken;

var $modalNew;
var $btnNew;
var $btnConfirmNew;

var $selectBranch;
var $selectCenter;
var $selectMember;

var $message;
var templateErrorList;

var _members;
var _members_list;
var _memberId;
var _urlCenters = "/api/v1/data_stores/member_id_generetors/fetch_members";

var _cacheDom = function() {
  $modalNew         = $("#modal-new");
  $btnNew           = $("#btn-new");
  $btnConfirmNew    = $("#btn-confirm-new");
  $selectBranch     = $("#select-branch");
  $selectCenter     = $("#select-center");
  $selectMember     = $("#select-member");
  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
}

var _loadMemberOptions  = function() {
  $selectMember.html("");
  if (_members_list.length > 0) {
    _memberId = _members_list[0].id;
    
    for(var i = 0; i < _members_list.length; i++) {
  
      $selectMember.append(new Option(_members_list[i].name, _members_list[i].id));
    }
    $selectMember.val(_memberId);
  }


}


var _bindEvents = function() {
  $selectCenter.on("change", function() {
  
    $.ajax({
      method: 'GET',
      url: _urlCenters,
      data: {
        id: $selectCenter.val(),
        with_members: true
      },
      success: function(response) {
        _members_list  = response.members;
        
        if(_members_list.length > 0) {
          _members  = _members_list[0].name;
          
        }

        _loadMemberOptions();
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching centers");
      }
    });

  });

}

var init  = function(config) {
  authenticityToken = config.authenticityToken;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
