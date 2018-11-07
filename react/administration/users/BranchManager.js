import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import BranchManagerDisplay from "./BranchManagerDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");

ReactDOM.render(
  <BranchManagerDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('branch-manager-content')
);
