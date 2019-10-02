var hiipClaimsForm = (function() {

  var $amount;
  var $numberOfDaysTobepaid;
 
  var _cacheDom = function() {
    $amount                 = $("#amount"); 
    $numberOfDaysTobepaid   = $("#number-ofdays-tobepaid")
 }

  var _bindEvents = function() {

    $numberOfDaysTobepaid.on('change', function() {
      var numberOfDaysTobepaid = $("#number-ofdays-tobepaid").val();
      var value = 200.00
      var hiip_total = 6000.00
      var amount = $("#amount").val();
      $('#amount').val(parseFloat(numberOfDaysTobepaid) * parseFloat(value))
      $('#balance').val(parseFloat(hiip_total) - (parseFloat(numberOfDaysTobepaid) * parseFloat(value)))

    });
  }

  var init = function() {
    _cacheDom();
    _bindEvents();
  }

  return {
    init: init
  };
})();

$(document).ready(function() {
  hiipClaimsForm.init();
});
