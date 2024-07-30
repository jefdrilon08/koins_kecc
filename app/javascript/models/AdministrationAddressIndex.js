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
var $regionTextbox;
var $regionid;


var _cacheDom = function() {
    $btnNew = $("#btn-new");
    $btnUpdate = $(".updateregion")
    $btnConfirm = $("#btn-confirm");
    $regionTextbox = $("#region-textbox");
    $regionid = $("#region-id");
    

    $modalNew = new bootstrap.Modal(
        document.getElementById('modal-new')
    );
};

var _bindEvents = function() {
 $btnNew.on("click",function(){
  $regionTextbox.val("");
  $regionid.val("");
 
    $modalNew.show();
 });

 $btnUpdate.on("click",function(){
    var _region_id = $(this).data("region-id")
    var _region_name = $(this).data("region-name")
    
    $regionid.val(_region_id)
    $regionTextbox.val(_region_name);
    $modalNew.show();
    $regionTextbox.focus()
    
 });

 $btnConfirm.on("click", function(){
  var region   = $regionTextbox.val().trim();
  var regionid = $regionid.val();

  if (!region) {
    showError($regionTextbox, "Input the region name!");
    return;
  }
  
  var data = {
    region: region,
    regionid: regionid,
    authenticity_token: _authenticityToken
  }

  $.ajax({
    url: "/api/v1/administration/admin_address/create",
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
      $message.html(
        Mustache.render(
          templateErrorList,
          { errors: errors }
        )
      );
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
