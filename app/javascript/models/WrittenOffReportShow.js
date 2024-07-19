import Mustache from "mustache";
import $ from "jquery";
import * as bootstrap from "bootstrap";

var authenticityToken;
var $message;


var _cacheDom = function() {
    $search_name = $("#search-name");
    $btnSearch = $("#search-button");
};

var _bindEvents = function() {
    $btnSearch.on("click", function() {
        var name = $search_name.val()
        _id = $(this).data("id")
        // console.log(_id)
        var data = {
            name: name,
            data_store_id: _id,
            authenticity_token: authenticityToken
        }
        $.ajax({
            url: "/api/v1/data_stores/written_off_report/fetch",
            method: 'GET',
            data: data,
            success: function(response) {
                window.location.reload();
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
