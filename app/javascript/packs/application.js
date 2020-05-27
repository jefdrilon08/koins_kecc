import 'core-js/stable'
import 'regenerator-runtime/runtime'
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

require("@rails/ujs").start()
require("@rails/activestorage").start()

import 'bootstrap';
import jquery from 'jquery';
import $ from 'jquery';

window.$ = window.jquery = jquery;

import "@fortawesome/fontawesome-free/js/all";

import '@coreui/coreui';

import "../stylesheets/application.scss";

import "../pages/Login.js";
import "../members/Index.js";
import "../members/Show.js";
import "../members/SurveyAnswer.js";
import "../loans/Show.js";
import "../billings/Index.js";

import MainUI from "../../../react/dashboard/MainUI";
import MembersFormDisplay from "../../../react/members/FormDisplay";
import SurveyAnswerUIDisplay from "../../../react/members/SurveyAnswerUIDisplay";
import LoanApplicationForm from "../../../react/loans/ApplicationFormComponent";
import LoanAccountingEntryComponent from "../../../react/loans/AccountingEntryComponent";

var Hooks = {};

// Router
$(document).ready(function() {
  var authenticityToken = $("meta[name='csrf-token']").attr('content');

  var $parameters = $("#parameters");
  var controller  = $parameters.data("controller");
  var action      = $parameters.data("action");

  console.log("Controller: " + controller + " Action: " + action);

  if(controller == "pages") {
    if(action == "login") {
      Login.init();
    } else if(action == "index") {
      var username  = $parameters.data('username');
      var roles     = $parameters.data('roles');

      ReactDOM.render(
        <MainUI
          authenticityToken={authenticityToken}
          username={username}
          roles={roles}
        />,
        document.getElementById('dashboard-content')
      );
    }
  } else if(controller == "members") {
    if(action == "index") {
      MembersIndex.init();
    } else if(action == "show") {
      var memberId  = $parameters.data("member-id");

      MembersShow.init(memberId, authenticityToken);
    } else if(action == "form") {
      var id          = $parameters.data("id");
      var memberTypes = $parameters.data("member-types");

      ReactDOM.render(
        <MembersFormDisplay
          authenticityToken={authenticityToken}
          memberTypes={memberTypes}
          id={id}
        />,
        document.getElementById('content')
      );
    } else if(action == "survey_answer_form") {
      var id        = $parameters.data("id");
      var memberId  = $parameters.data("member-id");

      ReactDOM.render(
        <SurveyAnswerUIDisplay
          authenticityToken={authenticityToken}
          memberId={memberId}
          id={id}
        />,
        document.getElementById('survey-answer-content')
      );
    } else if(action == "survey_answer") {
      var id        = $parameters.data("id");
      var memberId  = $parameters.data("member-id");

      SurveyAnswer.init({
        id: id,
        memberId: memberId,
        authenticityToken: authenticityToken
      });
    }
  } else if(controller == "loans") {
    if(action == "show") {
      var loanId    = $parameters.data("id");
      var memberId  = $parameters.data("member-id");

      LoansShow.init({
        loanId: loanId,
        authenticityToken: authenticityToken
      });

      ReactDOM.render(
        <LoanAccountingEntryComponent
          authenticityToken={authenticityToken}
          id={loanId}
          memberId={memberId}
        />,
        document.getElementById('loan-accounting-entry-content')
      );
    } else if(action == "form") {
      var id        = $parameters.data("id");
      var memberId  = $parameters.data("member-id");
      var banks     = $parameters.data("banks");

      ReactDOM.render(
        <LoanApplicationForm
          authenticityToken={authenticityToken}
          id={id}
          memberId={memberId}
          banks={banks}
        />,
        document.getElementById('loan-application-content')
      );
    }
  } else if(controller == "billings") {
    if(action == "index") {
      BillingsIndex.init({
        authenticityToken: authenticityToken
      });
    }
  }
});
