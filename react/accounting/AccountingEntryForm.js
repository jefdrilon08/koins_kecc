import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import AccountingEntryFormDisplay from "./AccountingEntryFormDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var $parameters       = $("#parameters");

var book  = $parameters.data("book");
var id    = $parameters.data("id");

var accountingFundId = ""

if ($parameters.data("accounting-fund-id")) {
  var accountingFundId = $parameters.data("accounting-fund-id");
}

var defaultBranch = false;

if($parameters.data("branch-id") && $parameters.data("branch-name")) {
  defaultBranch = {
    id: $parameters.data("branch-id"),
    name: $parameters.data("branch-name")
  };
  console.log(defaultBranch);
}

ReactDOM.render(
  <AccountingEntryFormDisplay
    authenticityToken={authenticityToken}
    defaultBranch={defaultBranch}
    book={book}
    accountingFundId={accountingFundId}
    id={id}
  />,
  document.getElementById('content')
);
