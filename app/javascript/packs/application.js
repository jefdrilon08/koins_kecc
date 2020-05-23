require("@rails/ujs").start()
require("@rails/activestorage").start()

// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);

import 'bootstrap';
import jquery from 'jquery';
import $ from 'jquery';
window.$ = window.jquery = jquery;

import "@fortawesome/fontawesome-free/js/all";

import '@coreui/coreui';

import "../stylesheets/application.scss";

import "../pages/Login.js";

import React from "react";
import ReactDOM from "react-dom";

import MainUI from "../../../react/dashboard/MainUI";

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
    }
  }
});
