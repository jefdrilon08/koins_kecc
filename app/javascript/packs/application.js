require("@rails/ujs").start()
require("@rails/activestorage").start()

import 'bootstrap';
import jquery from 'jquery';
import $ from 'jquery';
window.$ = window.jquery = jquery;

import "@fortawesome/fontawesome-free/js/all";

//import "mustache/mustache";
//import "datatables.net/js/jquery.dataTables";
//import "datatables.net-bs4/js/dataTables.bootstrap4";
//import "datatables.net-fixedheader/js/dataTables.fixedHeader";
//import "datatables.net-fixedheader-bs4/js/fixedHeader.bootstrap4";
//import "select2/dist/js/select2";

// Third party js
//import "../opt/coreui.min";
import { Sidebar } from '@coreui/coreui';

import "../stylesheets/application.scss";

import "../pages/Login.js";

var Hooks = {};

// Router
$(document).ready(function() {
  var authenticityToken = $("meta[name='csrf-token']").attr('content');

  var $parameters = $("#parameters");
  var controller  = $parameters.data("controller");
  var action      = $parameters.data("action");

  console.log("Controller: " + controller + " Action: " + action);

  if(controller == "pages" && action == "login") {
    Login.init();
  }
});
