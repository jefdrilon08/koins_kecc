import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import AccountingEntryPrecisionComponent from "./AccountingEntryPrecisionComponent";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var branches          = $("#parameters").data("branches");

ReactDOM.render(
  <AccountingEntryPrecisionComponent
    authenticityToken={authenticityToken}
    branches={branches}
  />,
  document.getElementById('content')
);
