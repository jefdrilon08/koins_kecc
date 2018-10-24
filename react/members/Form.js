import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import FormDisplay from "./FormDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var $parameters       = $("#parameters");

var id  = $parameters.data("id");

ReactDOM.render(
  <FormDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('content')
);
