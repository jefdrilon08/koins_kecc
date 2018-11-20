import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import ApplicationFormDisplay from "./ApplicationFormDisplay";

var $parameters       = $("#parameters");
var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $parameters.data("id");
var memberId          = $parameters.data("member-id");

ReactDOM.render(
  <ApplicationFormDisplay
    authenticityToken={authenticityToken}
    id={id}
    memberId={memberId}
  />,
  document.getElementById('loan-application-content')
);
