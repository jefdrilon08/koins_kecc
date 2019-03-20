import React from "react";
import ReactDom from "react-dom";
import $ from "jquery";

import InsuranceStatusComponent from "./InsuranceStatusComponent";

var memberAccountId = $("#parameters").data("member-account-id");
ReactDom.render(
	<InsuranceStatusComponent
	memberAccountId={memberAccountId}
	/>,
	document.getElementById("content-status")
	);