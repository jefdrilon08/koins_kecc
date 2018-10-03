import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import TrialBalanceDisplay from "./TrialBalanceDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');

ReactDOM.render(
  <TrialBalanceDisplay
    authenticityToken={authenticityToken}
  />,
  document.getElementById('content')
);
