import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var authenticityToken;
var $message;


var _cacheDom = function() {
    // $search_name = $("#search-name");
    // $btnSearch = $("#search-button");
    $btnDelete = $("#btn-delete");
    $btnConfirmDelete = $("#btn-confirm-delete");
    $modalDelete = new bootstrap.Modal(document.getElementById("modal-delete"));
};

var _bindEvents = function() {
    $btnDelete.on("click", function() {
        _id = $(this).data("id");
        $modalDelete.show();
       
    });

    $btnConfirmDelete.on("click", function(){
        var id = _id
        var data = {
            data_store_id: id,
            authenticity_token: authenticityToken
        }

        console.log(id);
        $.ajax({
            url: "/api/v1/data_stores/written_off_report/delete",
            method: 'POST',
            data: data,
            success: function(response) {
                window.location.href = "/data_stores/written_off_report";
            },
            error: function(response) {
                let errors = [];
                try {
                    errors = JSON.parse(response.responseText).full_messages;
                } catch (err) {
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

var init = function(config) {
    authenticityToken = config.authenticityToken;
    _cacheDom();
    _bindEvents();
};

export default { init: init };
