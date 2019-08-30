import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import AccountingEntryFormDisplay from "./AccountingEntryFormDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var $parameters       = $("#parameters");

var book  = $parameters.data("book");
var id    = $parameters.data("id");

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
    id={id}
  />,
  document.getElementById('content')
);
