import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import ShowComponent from "./ShowComponent";

var $parameters       = $("#parameters");
var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $parameters.data("id");
var start_date        = $parameters.data("start_date");
var end_date          = $parameters.data("end_date");
var branch_id         = $parameters.data("branch_id");


ReactDOM.render(
  <ShowComponent
    authenticityToken={authenticityToken}
    id={id}
    start_date={start_date}
    end_date={end_date}
    branch_id={branch_id}
  />,
  document.getElementById('content')
);
