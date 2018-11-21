import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import ApplicationFormDisplay from "./ApplicationFormDisplay";

var $parameters       = $("#parameters");
var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $parameters.data("id");
var memberId          = $parameters.data("member-id");
var banks             = $parameters.data("banks");

console.log(banks)

ReactDOM.render(
  <ApplicationFormDisplay
    authenticityToken={authenticityToken}
    id={id}
    memberId={memberId}
    banks={banks}
  />,
  document.getElementById('loan-application-content')
);
