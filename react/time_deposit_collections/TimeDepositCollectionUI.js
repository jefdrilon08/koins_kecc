import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import TimeDepositCollectionUIDisplay from "./TimeDepositCollectionUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");

ReactDOM.render(
  <TimeDepositCollectionUIDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('time-deposit-collection-content')
);
