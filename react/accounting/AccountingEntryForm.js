import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import AccountingEntryFormDisplay from "./AccountingEntryFormDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var $parameters       = $("#parameters");

var book  = $parameters.data("book");
var id    = $parameters.data("id");

ReactDOM.render(
  <AccountingEntryFormDisplay
    authenticityToken={authenticityToken}
    book={book}
    id={id}
  />,
  document.getElementById('content')
);
