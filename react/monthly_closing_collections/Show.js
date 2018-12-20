import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import ShowUI from "./ShowUI";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");

ReactDOM.render(
  <ShowUI
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('content')
);
