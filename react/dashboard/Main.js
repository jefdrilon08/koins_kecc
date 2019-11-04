import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import MainUI from "./MainUI";

var $parameters       = $("#parameters");
var authenticityToken = $("meta[name='csrf-token']").attr('content');
var username          = $parameters.data('username');
var roles             = $parameters.data('roles');

ReactDOM.render(
  <MainUI
    authenticityToken={authenticityToken}
    username={username}
    roles={roles}
  />,
  document.getElementById('dashboard-content')
);
