import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var _id;
var _authenticityToken;
var templateErrorList;
var $modalNew;
var $btnNew;
var $btnConfirm;
var $Selectdate;
var $holidayTextbox;
var $holidayid;
var $message;

var _cacheDom = function() {
    $btnNew         = $("#btn-new");
    $btnConfirm     = $("#btn-confirm");
    $Selectdate     = $("#input-as-of");
    $holidayTextbox = $("#holiday-textbox")
    $holidayid      = $("#holiday-id")
    $btnUpdate      = $("update-button");
    $message        = $(".message");

    $modalNew = new bootstrap.Modal(
        document.getElementById("modal-new")
    );
}

var _bindEvents = function() {
    $btnNew.on("click", function(){
        $message.html("");
        $Selectdate.val("");
        $holidayTextbox.val("");
        $holidayid.val("");
        $modalNew.show();
    });

    // btnUpdate
    $(document).on("click", ".update-button", function () {
        var _holidayId = $(this).data("holiday-id");
        var _holidayName = $(this).data("holiday-name");
        var _holidayDate = $(this).data("holiday-date");
        var _holidayStatus = $(this).data("holiday-status");

        // Pre-fill modal with holiday data
        $holidayid.val(_holidayId);
        $holidayTextbox.val(_holidayName);
        $Selectdate.val(_holidayDate);

        $modalNew.show();
    });

    $btnConfirm.on("click", function(){
        var holidayTextbox  = $holidayTextbox.val().trim();
        var selectDate      = $Selectdate.val();
        var holidayId       = $holidayid.val();

        // Clear previous message
        $message.html("");
        $message.removeClass("text-danger"); // Remove any previous error class

        // Validation checks
        var messages = {
            both: "Please provide fields.",
            holiday: "Please provide the holiday name.",
            date: "Please select a date."
        };

        var missingField = !holidayTextbox && !selectDate ? "both" : !holidayTextbox ? "holiday" : !selectDate ? "date" : null;

        if (missingField) {
            $message.html(messages[missingField]);
            $message.addClass("text-danger");
            return;
        }

        var data = {
            holiday_name: holidayTextbox,
            holiday_date: selectDate,
            status: "active",
            authenticity_token: _authenticityToken
        };

        if (holidayId) {
            data.id = holidayId; 
            $.ajax({
                url: "/api/v1/data_stores/holiday_records/update",
                method: 'PUT',
                data: data,
                success: function(response) {
                    alert("Successfully updated!");
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
        } else {
            // If no holidayId, create a new holiday record (POST)
            $.ajax({
                url: "/api/v1/data_stores/holiday_records/create",
                method: 'POST',
                data: data,
                success: function(response) {
                    alert("Successfully created!");
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
        }
    });

    // Delete button event
    $(document).on("click", ".delete-button", function() {
        var holidayId = $(this).data("holiday-id");

        // Clear previous messages
        $message.html("");
        $message.removeClass("text-danger");

        // Confirm before deletion
        if (confirm("Are you sure you want to delete this holiday record?")) {
            $.ajax({
                url: "/api/v1/data_stores/holiday_records/delete",
                method: "POST",
                data: {
                    holiday_id: holidayId,
                    authenticity_token: _authenticityToken
                },
                success: function(response) {
                    alert("Holiday record successfully deleted!");
                    window.location.reload(); // Refresh the page to reflect changes
                },
                error: function(response) {
                    var errors = [];
                    try {
                        errors = JSON.parse(response.responseText).messages;
                    } catch (err) {
                        errors.push("Something went wrong");
                        console.log(response);
                    }
                    $message.html(
                        Mustache.render(templateErrorList, { errors: errors })
                    );
                }
            });
        }
    });
}

var init = function(options) {
    _id                 = options.id;
    _authenticityToken  = options.authenticityToken;

    _cacheDom();
    _bindEvents();
};


export default { init: init };