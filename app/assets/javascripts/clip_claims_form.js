var clipClaimsForm = (function() {

  var $amountOfLoan;
  var $amountPayableToBeneficiary;
  var $amountPayableToCreditor;
 
  var _cacheDom = function() {
    $amountOfLoan                = $("#amount-of-loan"); 
    $amountPayableToBeneficiary  = $("#amount-payable-to-beneficiary");
    $amountPayableToCreditor     = $("#amount-payable-to-creditor");
 }

  var _bindEvents = function() {

    $amountPayableToBeneficiary.on('change', function() {
      var amountOfLoanValue = ($amountOfLoan.val());
      var amountPayableToBeneficiaryValue = ($amountPayableToBeneficiary.val());
      $('#amount-payable-to-creditor').val(parseFloat(amountOfLoanValue) - parseFloat(amountPayableToBeneficiaryValue))
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
  clipClaimsForm.init();
});
