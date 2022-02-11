import Mustache from "mustache/mustache";

var authenticityToken;

var $modalNew;
var $btnNew;
var $btnConfirmNew;

var $selectBranch;
var $selectCenter;
var $selectMember;
var $selectIdType;

var $btnDelete;


var $btnAdd;
var $modalContactPerson;
var $inputContactName;
var $inputContactNumber;
var $btnConfirmContactPerson;

var $labelMemberName
var $message;
var templateErrorList;

var _members;
var _members_list;
var _memberId;
var _urlCenters = "/api/v1/data_stores/member_id_generetors/fetch_members";
var _urlAddMember = "/api/v1/data_stores/member_id_generetors/add_member";
var _urlContactPerson = "/api/v1/data_stores/member_id_generetors/contact_person";
var _urlAddContactPerson = "/api/v1/data_stores/member_id_generetors/add_contact_person";

var _cacheDom = function() {
  $modalNew                 = $("#modal-new");
  $btnNew                   = $("#btn-new");
  $btnConfirmNew            = $("#btn-confirm-new");
  $selectBranch             = $("#select-branch");
  $selectCenter             = $("#select-center");
  $selectIdType             = $("#select-id-type");
  $selectMember             = $("#select-member");
  $btnAdd                   = $("#btn-add");
  $message                  = $(".message");
  $modalContactPerson       = $("#modal-contact-person");
  $inputContactName         = $("#contact-name");
  $inputContactNumber       = $("#contact-number");
  $btnConfirmContactPerson  = $("#btn-confirm-contact-person");
  $labelMemberName          = $("#member-name");

  templateErrorList   = $("#template-error-list").html();
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

  $btnConfirmContactPerson.on("click", function(){
    //alert($inputContactNumber.val())
    //$selectMember.val()
    //alert("jef")
    //alert($(this).data("id"))
    var data = {
      data_store: $(this).data("id"),
      member_id: $selectMember.val(),
      id_type: $selectIdType.val(),
      contact_person: $inputContactName.val(),
      contact_person_number: $inputContactNumber.val()
    }
    $.ajax({
      method: 'POST',
      url: _urlAddContactPerson,
      data: {
        data: data
      },
      success: function(response) {
        window.location.reload();
        
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching centers");
      }
    });
  });

  $btnAdd.on("click", function(){
  
     
    var config = {member_id: $selectMember.val()}
    
  
    //$inputContactName.val("jef")
    // var data_store = $(this).data("id")
    $.ajax({
      method: 'POST',
      url: _urlContactPerson,
      data: {
        member_id: $selectMember.val()
      },
      success: function(response) {
        $labelMemberName.text(response.member_name) 
        if (response.id != null){
          $inputContactName.val(response.id.name)
          $inputContactNumber.val(response.id.cNumber)
        }else{
          $inputContactName.val("")
          $inputContactNumber.val("")

        }
        
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching centers");
      }
    });
/*
    //$selectCenter.val()
    //$selectMember.val()
    */
    $modalContactPerson.modal("show");
  }) 

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
