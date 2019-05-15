import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import FormDisplay from "./FormDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var $parameters       = $("#parameters");

var id          = $parameters.data("id");
var memberTypes = $parameters.data("member-types");

ReactDOM.render(
  <FormDisplay
    authenticityToken={authenticityToken}
    memberTypes={memberTypes}
    id={id}
  />,
  document.getElementById('content')
);
