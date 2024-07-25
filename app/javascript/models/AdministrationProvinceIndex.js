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
var $provinceTextbox;
var $provinceid;
var $regionSelect;


var _cacheDom = function() {
    $btnNew = $("#btn-new");
    $btnConfirm = $("#btn-confirm");
    $provinceTextbox = $("#province-textbox");
    $provinceid = $("#province-id");
    $btnUpdate = $(".updateregion");
    $regionSelect = $("#region-select");

    $modalNew = new bootstrap.Modal(
        document.getElementById('modal-new')
    );
};

var _bindEvents = function() {
 $btnNew.on("click",function(){
  $provinceTextbox.val("");
  $provinceid.val("");
  $regionSelect.val("");
 
    $modalNew.show();
 });
 
//  btnUpdate
 $(document).on("click", ".updateprovince",function(){
    var _province_id = $(this).data("province-id")
    var _province_name = $(this).data("province-name")
    var _region_id = $(this).data("region-id");

    $provinceid.val(_province_id)
    $provinceTextbox.val(_province_name);
    $regionSelect.val(_region_id);

    $modalNew.show();
 });


 $btnConfirm.on("click", function(){
  var provinceName = $provinceTextbox.val().trim();
  var provinceId = $provinceid.val();
  var regionId = $regionSelect.val();

  if (!provinceName) {
    showError($provinceTextbox, "Input province name!")
    return;
  }
  if (!regionId) {
    showError($regionSelect, "Select region name!")
    return;
  }

  var data = {
    province_name: provinceName,
    provinceid: provinceId,
    region_id: regionId,
    authenticity_token: _authenticityToken
    
  }

  console.log("Data sent to server:", data); // Log the data object


  $.ajax({
    url: "/api/v1/administration/admin_province/create",
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
              { errors: errors}
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
