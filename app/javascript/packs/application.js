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

import MainUI from "../../../react/dashboard/MainUI";
import MembersFormDisplay from "../../../react/members/FormDisplay";

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
    }
  }
});
