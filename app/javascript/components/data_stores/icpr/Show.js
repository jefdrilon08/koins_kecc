import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";


import ShowComponent from "./ShowComponent";

var $parameters       = $("#parameters");
var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $parameters.data("id");


ReactDOM.render(
  <ShowComponent
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('display')
);
