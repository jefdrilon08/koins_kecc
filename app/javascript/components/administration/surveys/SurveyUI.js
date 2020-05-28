import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import SurveyUIDisplay from "./SurveyUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");

ReactDOM.render(
  <SurveyUIDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('survey-content')
);
