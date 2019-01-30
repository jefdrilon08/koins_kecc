import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import MainUI from "./MainUI";

var $parameters       = $("#parameters");
var authenticityToken = $("meta[name='csrf-token']").attr('content');


ReactDOM.render(
  <MainUI
    authenticityToken={authenticityToken}
  />,
  document.getElementById('dashboard-content')
);
