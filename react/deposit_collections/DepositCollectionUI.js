import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import DepositCollectionUIDisplay from "./DepositCollectionUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var centers			  = $("#parameters").data("centers");
var id                = $("#parameters").data("id");

ReactDOM.render(
  <DepositCollectionUIDisplay
    authenticityToken={authenticityToken}
    id={id}
    centers={centers}
  />,
  document.getElementById('deposit-collection-content')
);
