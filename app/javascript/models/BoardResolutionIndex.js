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
var $SelectMonth;
var $SelectYear;
var $SelectStatus;
var $txtBoardResolution;
var $btnCancel;
var $message;

var _cacheDom = function() {
    $btnNew       = $("#btn-new");
    $btnConfirm   = $("#btn-confirm");
    $btnCancel    = $(".btn[data-bs-dismiss='modal']");
    $Selectbranch = $("#select-branch");
    $SelectMonth  = $("#select-month");
    $SelectYear   = $("#select-year");
    $SelectStatus = $("#select-status");
    $txtBoardResolution = $("#input-board-resolution-number")
    $message      = $(".message");

    $modalNew = new bootstrap.Modal(
        document.getElementById("modal-new")
    );
}

var _bindEvents = function() {
    $btnNew.on("click", function(){
        $Selectbranch.val(""); 
        $message.html("");
        $SelectMonth.val("");
        $SelectYear.val("");
        $SelectStatus.val("");
        $txtBoardResolution.val("");
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
        var month  = $SelectMonth.val();
        var year   = $SelectYear.val();
        var status = $SelectStatus.val();
        var boardResolutionNumber = $txtBoardResolution.val();

         // Array to map month numbers to month names (1-based index)
         var monthNames = [
            "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", 
            "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
        ];

        var monthName = (month && month >= 1 && month <= 12) ? monthNames[month - 1] : null;
        var yearString = (year) ? year.toString() : null;

        if (!branch || branch == "-- SELECT --") {
            $message.html("Please select a branch.");
            $message.addClass("text-danger");
            console.error("No branch selected.");
            return;
        }

        if (!month || !year) {
            $message.html("Please select both month and year.");
            $message.addClass("text-danger");
            console.error("No month or year selected.");
            return;
        }

        if (!status) {
            $message.html("Please select a status.");
            $message.addClass("text-danger");
            console.error("No status selected.");
            return;
        }

        if (!boardResolutionNumber) {
            $message.html("Please provide a board resolution number.");
            $message.addClass("text-danger");
            console.error("No board resolution number provided.");
            return;
        }

        $message.removeClass("text-danger");
        $message.html("Loading...");
        $btnConfirm.prop("disabled", false);
        
        $.ajax({
            url: "/api/v1/data_stores/board_resolution/create",
            method: 'POST',
            data: {
                branch_id: branch,
                month: monthName,
                year: yearString,
                status: status,
                board_resolution_number: boardResolutionNumber,
                authenticity_token: _authenticityToken
            },
            success: function(response) {
                alert("Successfully saved!");
                $modalNew.hide();
                window.location.reload();
            },
            error: function(response) {
                // Validate create for duplicate board resolution number.
                var templateErrorList = `<ul>{{#errors}}<li>{{.}}</li>{{/errors}}</ul>`;
                var errors = [];
                try {
                    var errorData = JSON.parse(response.responseText);
                    errors = Array.isArray(errorData.messages) ? 
                            errorData.messages.map(err => err.message) : 
                            [errorData.messages || "An unexpected error occurred."];
                } catch {
                    errors.push("Something went wrong. Please try again.");
                    console.log(response);
                }
                $btnConfirm.prop("disabled", false);
                $message.html(Mustache.render(templateErrorList, { errors })).addClass("text-danger");
            }
        });

    });

    $btnCancel.on("click", function() {
        $Selectbranch.val("");
        $SelectMonth.val("");
        $SelectYear.val("");
        $SelectStatus.val(""); 
        $("#board-resolution-number").val(""); 
        $message.html("");
        $message.removeClass("text-danger");
        $btnConfirm.prop("disabled", false);
        updateModalTitle("");
    });

    function updateModalTitle(branchName) {
        var title = branchName ? `Board Resolution Records for ${branchName}` : 'Board Resolution Records';
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