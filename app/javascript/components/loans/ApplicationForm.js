import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import ApplicationFormComponent from "./ApplicationFormComponent";

var $parameters       = $("#parameters");
var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $parameters.data("id");
var memberId          = $parameters.data("member-id");
var banks             = $parameters.data("banks");

console.log(banks)

ReactDOM.render(
  <ApplicationFormComponent
    authenticityToken={authenticityToken}
    id={id}
    memberId={memberId}
    banks={banks}
  />,
  document.getElementById('loan-application-content')
);
