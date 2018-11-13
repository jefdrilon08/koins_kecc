import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import ApplicationFormDisplay from "./ApplicationFormDisplay";

var $parameters       = $("#parameters");
var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $parameters.data("id");

ReactDOM.render(
  <BillingUIDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('loan-application-content')
);
