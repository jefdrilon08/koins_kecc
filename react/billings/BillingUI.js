import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import BillingUIDisplay from "./BillingUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");

ReactDOM.render(
  <BillingUIDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('billing-content')
);
