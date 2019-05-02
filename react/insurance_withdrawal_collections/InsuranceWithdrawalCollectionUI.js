import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import InsuranceWithdrawalCollectionUIDisplay from "./InsuranceWithdrawalCollectionUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");

ReactDOM.render(
  <InsuranceWithdrawalCollectionUIDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('insurance-withdrawal-collection-content')
);
