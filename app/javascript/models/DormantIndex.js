import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var _id;
var _authenticityToken;
var templateErrorList;

var $modalNew;
var $btnNew;
var $btnConfirm;
var $Selectbranch;
var $Selectdate;
var $btnCancel;
var $message;
// var $modalApproveTransaction;

var _cacheDom = function() {
    $btnNew       = $("#btn-new");
    $btnConfirm   = $("#btn-confirm");
    $btnCancel    = $(".btn[data-bs-dismiss='modal']");
    $Selectbranch = $("#select-branch");
    $Selectdate   = $("#input-as-of");
    $message      = $(".message");

    $modalNew = new bootstrap.Modal(
        document.getElementById("modal-new")
    );
    // $modalApproveTransaction = new bootstrap.Modal(
    //     document.getElementById("modal-approve-transaction")
    // )
}

var _bindEvents = function() {
    $btnNew.on("click", function(){
        $Selectbranch.val(""); 
        $Selectdate.val("");   
        $message.html("");
        $modalNew.show();
        updateModalTitle("");
    });
    
    $Selectbranch.on("change", function() {
        var selectedBranch = $(this).find("option:selected").text();

        if (selectedBranch === "-- SELECT --") {
            updateModalTitle("");
        } else {
            updateModalTitle(selectedBranch);
        }
    });

    $btnConfirm.on("click", function(){
        var branch  = $Selectbranch.val();
        var date    = $Selectdate.val();

        console.log("Branch selected:", branch);
        console.log("Date selected:", date);

        if (!branch) {
            $message.html("Please select a branch.");
            $message.addClass("text-danger");
            console.error("No branch selected.");
            return;
        }

        if (!date) {
            $message.html("Please select a date.");
            $message.addClass("text-danger");
            console.error("No date selected.");
            return;
        }

        $message.removeClass("text-danger");
        $message.html("Loading...");
        $btnConfirm.prop("disabled", true);
        
        $.ajax({
            url: "/api/v1/data_stores/dormants/create",
            method: 'POST',
            data: {
                branch_id: branch,
                as_of: date,
                authenticity_token: _authenticityToken
            },
            success: function(response) {
                alert("Successfully saved!");
                window.location.reload();
            },
            error: function(response) {
                var errors = [];
                try {
                    errors = JSON.parse(response.responseText).messages;
                } catch(err) {
                    errors.push("Something went wrong");
                    console.log(response);
                }
                $message.html(
                    Mustache.render(templateErrorList, { errors: errors })
                );
            }
        });

    });

    $btnCancel.on("click", function() {
        $Selectbranch.val("");
        $Selectdate.val("");
        $message.html("");
        $message.removeClass("text-danger");
        $btnConfirm.prop("disabled", false);
        updateModalTitle("");
    });

    function updateModalTitle(branchName) {
        var title = branchName ? `Dormant Records for ${branchName}` : 'Dormant Records';
        $(".modal-title").text(title);
    }

}

var init = function(options) {
    _id                 = options.id;
    _authenticityToken  = options.authenticityToken;

    _cacheDom();
    _bindEvents();
};


export default { init: init };