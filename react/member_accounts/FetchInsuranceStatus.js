import React from "react"
import ReactDOM from "react-dom"
import $ from "jquery";

import InsuranceStatusComponent from "./InsuranceStatusComponent"

var memberAccountId = $("#parameters").data("member-account-id");

ReactDOM.render(
	<InsuranceStatusComponent
	memberAccountId={memberAccountId}
	/>,
	document.getElementById("content-status")
	);