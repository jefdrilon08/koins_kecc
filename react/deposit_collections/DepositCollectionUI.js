import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import DepositCollectionUIDisplay from "./DepositCollectionUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");

ReactDOM.render(
  <DepositCollectionUIDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('deposit-collection-content')
);
