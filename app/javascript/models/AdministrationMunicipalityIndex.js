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
var $municipalityTextbox;
var $municipalityid;
var $provinceSelect;


var _cacheDom = function() {
    $btnNew = $("#btn-new");
    $btnUpdate = $(".updateregion")
    $btnConfirm = $("#btn-confirm");
    $municipalityTextbox = $("#municipality-textbox");
    $municipalityid = $("#municipality-id");
    $provinceSelect = $("#province-select");
    

    $modalNew = new bootstrap.Modal(
        document.getElementById('modal-new')
    );

    // $modalUpdate = new bootstrap.Modal(
    //   document.getElementById('modal-update')
    // );
};

var _bindEvents = function() {
 $btnNew.on("click",function(){
  $municipalityTextbox.val("");
  $municipalityid.val("");
  $provinceSelect.val("");

    $modalNew.show();
 });

 $btnUpdate.on("click",function(){
    var _municipality_id = $(this).data("municipality-id")
    var _municipality_name = $(this).data("municipality-name")
    var _province_id = $(this).data("province-id")
    
    $municipalityid.val(_municipality_id)
    $municipalityTextbox.val(_municipality_name);
    $provinceSelect.val(_province_id);
    
    $modalNew.show();
    
  });

 $btnConfirm.on("click", function(){
  var municipality   = $municipalityTextbox.val().trim();
  var municipalityid = $municipalityid.val();
  var provinceId     = $provinceSelect.val();

  if (!municipality) {
    showError($municipalityTextbox, "Input the municipality name!");
    return;
  }
  if (!provinceId) {
    showError($provinceSelect, "Select the province name!");
    return;
  }

  var data = {
    municipality: municipality,
    municipalityid: municipalityid,
    province_id:  provinceId,
    authenticity_token: _authenticityToken
    
  }

  $.ajax({
    url: "/api/v1/administration/admin_municipality/create",
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
