import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import SurveyAnswerUIDisplay from "./SurveyAnswerUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");
var memberId          = $("#parameters").data("member-id");

ReactDOM.render(
  <SurveyAnswerUIDisplay
    authenticityToken={authenticityToken}
    memberId={memberId}
    id={id}
  />,
  document.getElementById('survey-answer-content')
);
