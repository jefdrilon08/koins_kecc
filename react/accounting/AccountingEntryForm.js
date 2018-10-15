import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import AccountingEntryFormDisplay from "./AccountingEntryFormDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var $parameters       = $("#parameters");

var book            = $parameters.data("book");
var referenceNumber = $parameters.data("reference-number");
var branchId        = $parameters.data("branch-id");

ReactDOM.render(
  <AccountingEntryFormDisplay
    authenticityToken={authenticityToken}
    book={book}
    referenceNumber={referenceNumber}
    branchId={branchId}
  />,
  document.getElementById('content')
);
