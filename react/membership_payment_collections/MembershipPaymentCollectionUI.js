import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import MembershipPaymentCollectionUIDisplay from "./MembershipPaymentCollectionUIDisplay";

var authenticityToken = $("meta[name='csrf-token']").attr('content');
var id                = $("#parameters").data("id");

ReactDOM.render(
  <MembershipPaymentCollectionUIDisplay
    authenticityToken={authenticityToken}
    id={id}
  />,
  document.getElementById('membership-payment-collection-content')
);
