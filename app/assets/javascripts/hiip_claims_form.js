var hiipClaimsForm = (function() {

  var $amount;
  var $numberOfDaysTobepaid;
  var $effectiveDateOfCoverage;
 
  var _cacheDom = function() {
    $amount                   = $("#amount"); 
    $numberOfDaysTobepaid     = $("#number-ofdays-tobepaid");
    $effectiveDateOfCoverage  = $("#effective-date-of-coverage");
    $dateAdmitted             = $("#date-admitted");
    $dateDischarged             = $("#date-discharged");
 }

  var _bindEvents = function() {

    // $numberOfDaysTobepaid.on('change', function() {

    //   var numberOfDaysTobepaid = $("#number-ofdays-tobepaid").val();
    //   var value = 200.00;
    //   $('#amount').val(parseFloat(numberOfDaysTobepaid) * parseFloat(value));
     
    // });
    $dateDischarged.on('change', function() {

      var dateAdmitted = $("#date-admitted").val();
      var dateDischarged = $("#date-discharged").val();

      var dateDischargedValue = new Date(dateDischarged);
      var dateAdmittedValue = new Date(dateAdmitted);

      var time = dateDischargedValue.getTime() - dateAdmittedValue.getTime(); 
      var days = time / (1000 * 3600 * 24); 

      $('#number-ofdays-tobepaid').val(days);
      var numberOfDaysTobepaid = $("#number-ofdays-tobepaid").val();
      var value = 200.00;
      $('#amount').val(parseFloat(numberOfDaysTobepaid) * parseFloat(value));
     
    });
    $effectiveDateOfCoverage.on('change', function(){
     
            var effectiveDateOfCoverage = $("#effective-date-of-coverage").val();
            var expireDate = new Date(effectiveDateOfCoverage);
            expireDate.setFullYear(expireDate.getFullYear() + 1);
            expireDate.setDate(expireDate.getDate() -1);
            var dd = expireDate.getDate();
            var mm = expireDate.getMonth() + 1;
            var y = expireDate.getFullYear();            
            $("#expiration-date-of-coverage").val(dd + "/" + mm + "/" + y);

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
