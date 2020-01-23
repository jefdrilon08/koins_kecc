import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import InsuranceFundTransferCollectionUIDisplay from "./InsuranceFundTransferCollectionUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var centers			  = $("#parameters").data("centers");
var id                = $("#parameters").data("id");

ReactDOM.render(
  <InsuranceFundTransferCollectionUIDisplay
    authenticityToken={authenticityToken}
    centers={centers}
    id={id}
  />,
  document.getElementById('insurance-fund-transfer-collection-content')
);
