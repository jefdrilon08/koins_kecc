import Mustache from "mustache";
import $ from "jquery";
import { func } from "prop-types";
import * as bootstrap from "bootstrap";

var $message;
var templateErrorList;
var _id;
var _authenticityToken;
var $btnNew;
var $btnConfirm;
var $modalNew;
var $barangayTextbox;
var $barangayid;
var $municipalitySelect;


var _cacheDom = function() {
    $btnNew = $("#btn-new");
    $btnUpdate = $(".updatebarangay")
    $btnConfirm = $("#btn-confirm");
    $barangayTextbox = $("#barangay-textbox");
    $barangayid = $("#barangay-id");
    $municipalitySelect = $("#municipality-select");
    

    $modalNew = new bootstrap.Modal(
        document.getElementById('modal-new')
    );

    // $modalUpdate = new bootstrap.Modal(
    //   document.getElementById('modal-update')
    // );
};

var _bindEvents = function() {
 $btnNew.on("click",function(){
  $barangayTextbox.val("");
  $barangayid.val("");
  $municipalitySelect.val();
 
    $modalNew.show();
 });

 $btnUpdate.on("click",function(){
    var _barangay_id = $(this).data("barangay-id")
    var _barangay_name = $(this).data("barangay-name")
    var _municipality_id = $(this).data("municipality-id")
    
    $barangayid.val(_barangay_id)
    $barangayTextbox.val(_barangay_name);
    $municipalitySelect.val(_municipality_id);
    // console.log("Barangay:" + _barangay_name);
    $modalNew.show();
    
 });

 $btnConfirm.on("click", function(){
  var barangay   = $barangayTextbox.val();
  var barangayid = $barangayid.val();
  var municipalityId = $municipalitySelect.val();

  if (!barangay) {
      showError($barangayTextbox, "Input the barangay name!");
      return;
  }

  if (!municipalityId) {
      showError($municipalitySelect, "Select the municipality name!");
      return;
  }
  
  var data = {
    barangay: barangay,
    barangayid: barangayid,
    municipality_id: municipalityId,
    authenticity_token: _authenticityToken
  }

  $.ajax({
    url: "/api/v1/administration/admin_barangay/create",
    method: 'POST',
    data: data,
    success: function(response) {   
      alert("Successfuly Saved!")
     window.location.reload();       
    },
    error: function(response) {     
      errors = [];
      try {
        errors = JSON.parse(response.responseText).full_messages;
      } catch(err) {
        errors.push("Something went wrong");
        console.log(response);          
      }
    //   $message.html(
    //     Mustache.render(
    //       templateErrorList,
    //       { errors: errors }
    //     )
    //   );
    } 
  });

 });

};

var init = function(options) {
  _id                 = options.id;
  _authenticityToken  = options.authenticityToken;

  _cacheDom();
  _bindEvents();
};

export default { init: init };
