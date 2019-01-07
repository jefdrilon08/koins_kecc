import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import AccountingEntrySubsidiaryBalancingComponent from "./AccountingEntrySubsidiaryBalancingComponent";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var branches          = $("#parameters").data("branches");
var asOf              = $("#parameters").data("as-of");

ReactDOM.render(
  <AccountingEntrySubsidiaryBalancingComponent
    authenticityToken={authenticityToken}
    branches={branches}
    asOf={asOf}
  />,
  document.getElementById('content')
);
