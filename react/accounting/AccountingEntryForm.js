import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import AccountingEntryFormDisplay from "./AccountingEntryFormDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var accountingEntryId = $("#parameters").data('accounting-entry-id');

ReactDOM.render(
  <AccountingEntryFormDisplay
    authenticityToken={authenticityToken}
    accountingEntryId={accountingEntryId}
  />,
  document.getElementById('content')
);
