// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require jquery/dist/jquery
//= require bootstrap/dist/js/bootstrap
//= require mustache/mustache
//= require datatables.net/js/jquery.dataTables
//= require datatables.net-bs4/js/dataTables.bootstrap4
//= require datatables.net-fixedheader/js/dataTables.fixedHeader
//= require datatables.net-fixedheader-bs4/js/fixedHeader.bootstrap4
//= require cocoon
//= require select2
//= require cable

$(document).ready(function(){
  // Turn on js-selectable class so that it becomes SELCT 2 tag
  $('.js-searchable').select2({
    allowClear: true,
    width: "auto",
    theme: "bootstrap"
  });
});

var encodeQueryData = function(data) {
  var ret = []
  for(var d in data) {
    ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
  }

  return ret.join("&");
};
