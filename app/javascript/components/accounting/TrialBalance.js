import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import TrialBalanceComponent from "./TrialBalanceComponent";

var $parameters = $("#parameters");

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var accountingFunds   = $parameters.data("accounting-funds");

console.log(accountingFunds);

ReactDOM.render(
  <TrialBalanceComponent
    authenticityToken={authenticityToken}
    accountingFunds={accountingFunds}
  />,
  document.getElementById('content')
);
