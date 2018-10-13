import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import FormDisplay from "./FormDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');

ReactDOM.render(
  <FormDisplay
    authenticityToken={authenticityToken}
  />,
  document.getElementById('content')
);
