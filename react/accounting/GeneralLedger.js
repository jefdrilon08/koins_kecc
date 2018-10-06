import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import GeneralLedgerDisplay from "./GeneralLedgerDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');

ReactDOM.render(
  <GeneralLedgerDisplay
    authenticityToken={authenticityToken}
  />,
  document.getElementById('content')
);
