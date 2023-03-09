import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var authenticityToken;

var $modalDetails;
var $btnDetails;
var $btnPrint;
var $btnConfirm;
var $member_name;
var $currentMember = "";
var $currentMemberId= "";
let $loan_records = [];
let $member_accounts = [];
var errors;
var id;
var _cacheDom = function() {
  $modalDetails = new bootstrap.Modal(
    document.getElementById("modal-details")
  );

  $btnPrint = $(".btn-print-letter");
  $member_name = $(".display-member");
  $btnConfirm = $(".btn-confirm");

  $message          = $(".message");
  templateErrorList = $("#template-error-list").html();
  var id = _id;
}

var _bindEvents = function() {
	$btnPrint.on("click", function() {
    $currentMember = $(this).data("member-name");
    $currentMemberId = $(this).data("member-id");
    $loan_records = $(this).data("loan-records");
    $member_accounts = $(this).data("member-accounts");
    $member_name.html($currentMember);
    $modalDetails.show();
	});

  $btnConfirm.on("click", function() {
   
    var data = {
      id: _id,
      member_id: $currentMemberId,
      loan_records: $loan_records,
      member_accounts: $member_accounts,
      authenticity_token: authenticityToken
    }
    const dataStr = JSON.stringify(data);
    console.log(dataStr);
    $modalDetails.hide();
    window.open("/print?data="+ encodeURIComponent(dataStr) + "&type=print_involuntary_members");

    // $.ajax({
    //   url: "/api/v1/data_stores/involuntary_members/print",
    //   method: "POST",
    //   data: data,

    //   success: function(response){

    //   },
    //   error: function(response){
    //     var errors  = [];

    //     try {
    //       errors  = JSON.parse(response.responseText).full_messages;
    //     }
    //     catch(err) {
    //       errors  = ["Something went wrong"]
    //     }
    //     finally {
    //       $message.html(
    //         Mustache.render(
    //           templateErrorList,
    //           { errors: errors }
    //         )
    //       );

          
    //     } 
    //   }
    // });
  

  })






 
}

var init  = function(config) {
  authenticityToken = config.authenticityToken;
  _id = config.id;

  _cacheDom();
  _bindEvents();
}

export default { init: init };
