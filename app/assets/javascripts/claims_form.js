var claimsForm = (function() {

  var $typeOfInsurancePolicy;
  var $classificationOfInsured;
  var $dateOfPolicyIssue;
  var $dateOfDeathTpdAccident;
  var $arrears;
 
  var _cacheDom = function() {
    $typeOfInsurancePolicy      = $("#type-of-insurance-policy");
    $classificationOfInsured    = $("#classification-of-insured");
    $dateOfPolicyIssue          = $("#date-of-policy-issue");
    $dateOfDeathTpdAccident     = $("#date-of-death-tpd-accident"); 
    $returnedContribution       = $("#returned-contribution");
    $returnedContributionField  = $(".returned-contribution-field");
    $totalAmountPayable         = $("#total-amount-payable");
    $arrears                    = $("#arrears");
    $orderOfChildField          = $(".order-of-child-field");
  }

  var _bindEvents = function() {

  var typeOfInsurancePolicyValue = ($typeOfInsurancePolicy.val());
  var classificationOfInsuredValue = ($classificationOfInsured.val());
  
  if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Child)"){
    $orderOfChildField.show();
  }
  else{
    $orderOfChildField.hide();  
  }
  

  $dateOfDeathTpdAccident.on('change', function() {
    var typeOfInsurancePolicyValue = ($typeOfInsurancePolicy.val());
    var classificationOfInsuredValue = ($classificationOfInsured.val());  
    var dateOfPolicyIssueValue = ($dateOfPolicyIssue.val());
    var dateOfDeathTpdAccidentValue = ($dateOfDeathTpdAccident.val());
    var recognitionDate = new Date(dateOfPolicyIssueValue);
    var dateOfResignation = new Date(dateOfDeathTpdAccidentValue);
    var currentDate = new Date();
    var seconds = Math.abs( dateOfResignation - recognitionDate ) / 1000;
    var daysBetween = Math.abs(((seconds / 60) / 60) / 24);
    var numberOfDays = Math.floor(daysBetween);
    var numberOfMonths = Math.floor(daysBetween / 30.44);
    var years = Math.floor(daysBetween / 365.242199);
    var months = (numberOfMonths - (years * 12));

      if (years < 1){
        if (months > 1){
          var stay = months + " Months"
          $('#length-of-stay').val(stay)
        }else if (months == 1){
          var stay = months + " Months"
          $('#length-of-stay').val(stay)
        }else if (months < 1) {
          if (numberOfDays == 1){
            var stay = numberOfDays + " Day"
            $('#length-of-stay').val(stay)  
          }else if (numberOfDays > 1){
            var stay = numberOfDays + " Day"
            $('#length-of-stay').val(stay)  
          }else if (numberOfDays < 1){
            var stay = ""
            $('#length-of-stay').val(stay)  
          }
        }  
      }else{
        if (years == 1 && months == 0){
          var stay = years + " Year"
          $('#length-of-stay').val(stay)
        }else if (years == 1 && months == 1){
          var stay = years + " Year and, " + months + " months" 
          $('#length-of-stay').val(stay)
        }else if (years == 1 && months > 1){
          var stay = years + " Year and, " + months + " months"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months  > 0){
          var stay = years + " Years and, " + months + " months"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months == 1){
          var stay = years + " Years and, " + months + " month"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months < 1){
          var stay = years + " Years"
          $('#length-of-stay').val(stay)
        }
      }
 
    // if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Member"){ 
      if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Member" || typeOfInsurancePolicyValue == "TPD"  && classificationOfInsuredValue == "Member"){  
        if (months < 3 && years < 1){
            var value = 2000.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 6000.00
          }
          else if (years >= 1 && years < 2){
           var value = 10000.00
          }
          else if (years >= 2 && years < 3){
            var value = 30000.00
          }
          else if (years >= 3){
            var value = 50000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.show();
      } else if(typeOfInsurancePolicyValue == "Accidental Death"  && classificationOfInsuredValue == "Member") {
        if (months < 3 && years < 1){
            var value = 2000.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 12000.00
          }
          else if (years >= 1 && years < 2){
           var value = 20000.00
          }
          else if (years >= 2 && years < 3){
            var value = 60000.00
          }
          else if (years >= 3){
            var value = 100000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.show();
      } else if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Parent)" || typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Child)" ||typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Parent)"){
        if (months < 3 && years < 1){
            var value = 0.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 5000.00
          }
          else if (years >= 1 && years < 2){
           var value = 5000.00
          }
          else if (years >= 2 && years < 3){
            var value = 10000.00
          }
          else if (years >= 3){
            var value = 10000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.hide();
      } else if(typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Parent)") {
        if (months < 3 && years < 1){
            var value = 0.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 5000.00
          }
          else if (years >= 1 && years < 2){
           var value = 5000.00
          }
          else if (years >= 2 && years < 3){
            var value = 10000.00
          }
          else if (years >= 3){
            var value = 10000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.hide();
      } else if(typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Parent)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Member") {
        var value = 0.00

        $('#face-amount').val(value);
      }
    });

    $returnedContribution.on('change', function() { 
      var value = $('#face-amount').val() 
      var return_contri = $('#returned-contribution').val()
      $('#total-amount-payable').val(parseFloat(value) + parseFloat(return_contri))
    });

    $arrears.on('change', function() { 
      var value       = $('#total-amount-payable').val() 
      var arrears_val = $('#arrears').val()
      $('#total-amount-payable').val(parseFloat(value) - parseFloat(arrears_val))
    });

    $classificationOfInsured.on('change', function() { 
      var typeOfInsurancePolicyValue = ($typeOfInsurancePolicy.val());
      var classificationOfInsuredValue = ($classificationOfInsured.val());

      if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Child)"){
        $orderOfChildField.show();
      }
      else{
        $orderOfChildField.hide();
      }  
    });

    $typeOfInsurancePolicy.on('change', function(){
      
      var typeOfInsurancePolicyValue = ($typeOfInsurancePolicy.val());
      var classificationOfInsuredValue = ($classificationOfInsured.val());  
      var dateOfPolicyIssueValue = ($dateOfPolicyIssue.val());
      var dateOfDeathTpdAccidentValue = ($dateOfDeathTpdAccident.val());
      var recognitionDate = new Date(dateOfPolicyIssueValue);
      var dateOfResignation = new Date(dateOfDeathTpdAccidentValue);
      var currentDate = new Date();
      var seconds = Math.abs( dateOfResignation - recognitionDate ) / 1000;
      var daysBetween = Math.abs(((seconds / 60) / 60) / 24);
      var numberOfDays = Math.floor(daysBetween);
      var numberOfMonths = Math.floor(daysBetween / 30.44);
      var years = Math.floor(daysBetween / 365.242199);
      var months = (numberOfMonths - (years * 12));

      if (years < 1){
        if (months > 1){
          var stay = months + " Months"
          $('#length-of-stay').val(stay)
        }else if (months == 1){
          var stay = months + " Months"
          $('#length-of-stay').val(stay)
        }else if (months < 1) {
          if (numberOfDays == 1){
            var stay = numberOfDays + " Day"
            $('#length-of-stay').val(stay)  
          }else if (numberOfDays > 1){
            var stay = numberOfDays + " Day"
            $('#length-of-stay').val(stay)  
          }else if (numberOfDays < 1){
            var stay = ""
            $('#length-of-stay').val(stay)  
          }
        }  
      }else{
        if (years == 1 && months == 0){
          var stay = years + " Year"
          $('#length-of-stay').val(stay)
        }else if (years == 1 && months == 1){
          var stay = years + " Year and, " + months + " months" 
          $('#length-of-stay').val(stay)
        }else if (years == 1 && months > 1){
          var stay = years + " Year and, " + months + " months"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months  > 0){
          var stay = years + " Years and, " + months + " months"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months == 1){
          var stay = years + " Years and, " + months + " month"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months < 1){
          var stay = years + " Years"
          $('#length-of-stay').val(stay)
        }
      }
      if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Member" || typeOfInsurancePolicyValue == "TPD"  && classificationOfInsuredValue == "Member"){  
        if (months < 3 && years < 1){
            var value = 2000.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 6000.00
          }
          else if (years >= 1 && years < 2){
           var value = 10000.00
          }
          else if (years >= 2 && years < 3){
            var value = 30000.00
          }
          else if (years >= 3){
            var value = 50000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.show();
      } else if(typeOfInsurancePolicyValue == "Accidental Death"  && classificationOfInsuredValue == "Member") {
        if (months < 3 && years < 1){
            var value = 2000.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 12000.00
          }
          else if (years >= 1 && years < 2){
           var value = 20000.00
          }
          else if (years >= 2 && years < 3){
            var value = 60000.00
          }
          else if (years >= 3){
            var value = 100000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.show();
      } else if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Parent)" || typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Child)" ||typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Parent)"){
        if (months < 3 && years < 1){
            var value = 0.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 5000.00
          }
          else if (years >= 1 && years < 2){
           var value = 5000.00
          }
          else if (years >= 2 && years < 3){
            var value = 10000.00
          }
          else if (years >= 3){
            var value = 10000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.hide();
      } else if(typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Parent)") {
        if (months < 3 && years < 1){
            var value = 0.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 5000.00
          }
          else if (years >= 1 && years < 2){
           var value = 5000.00
          }
          else if (years >= 2 && years < 3){
            var value = 10000.00
          }
          else if (years >= 3){
            var value = 10000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.hide();
      } else if(typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Parent)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Member") {
        var value = 0.00

        $('#face-amount').val(value);
      }
    });
    $classificationOfInsured.on('change', function(){
      
      var typeOfInsurancePolicyValue = ($typeOfInsurancePolicy.val());
      var classificationOfInsuredValue = ($classificationOfInsured.val());  
      var dateOfPolicyIssueValue = ($dateOfPolicyIssue.val());
      var dateOfDeathTpdAccidentValue = ($dateOfDeathTpdAccident.val());
      var recognitionDate = new Date(dateOfPolicyIssueValue);
      var dateOfResignation = new Date(dateOfDeathTpdAccidentValue);
      var currentDate = new Date();
      var seconds = Math.abs( dateOfResignation - recognitionDate ) / 1000;
      var daysBetween = Math.abs(((seconds / 60) / 60) / 24);
      var numberOfDays = Math.floor(daysBetween);
      var numberOfMonths = Math.floor(daysBetween / 30.44);
      var years = Math.floor(daysBetween / 365.242199);
      var months = (numberOfMonths - (years * 12));

      if (years < 1){
        if (months > 1){
          var stay = months + " Months"
          $('#length-of-stay').val(stay)
        }else if (months == 1){
          var stay = months + " Months"
          $('#length-of-stay').val(stay)
        }else if (months < 1) {
          if (numberOfDays == 1){
            var stay = numberOfDays + " Day"
            $('#length-of-stay').val(stay)  
          }else if (numberOfDays > 1){
            var stay = numberOfDays + " Day"
            $('#length-of-stay').val(stay)  
          }else if (numberOfDays < 1){
            var stay = ""
            $('#length-of-stay').val(stay)  
          }
        }  
      }else{
        if (years == 1 && months == 0){
          var stay = years + " Year"
          $('#length-of-stay').val(stay)
        }else if (years == 1 && months == 1){
          var stay = years + " Year and, " + months + " months" 
          $('#length-of-stay').val(stay)
        }else if (years == 1 && months > 1){
          var stay = years + " Year and, " + months + " months"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months  > 0){
          var stay = years + " Years and, " + months + " months"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months == 1){
          var stay = years + " Years and, " + months + " month"
          $('#length-of-stay').val(stay)
        }else if (years > 1 && months < 1){
          var stay = years + " Years"
          $('#length-of-stay').val(stay)
        }
      }
      if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Member" || typeOfInsurancePolicyValue == "TPD"  && classificationOfInsuredValue == "Member"){  
        if (months < 3 && years < 1){
            var value = 2000.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 6000.00
          }
          else if (years >= 1 && years < 2){
           var value = 10000.00
          }
          else if (years >= 2 && years < 3){
            var value = 30000.00
          }
          else if (years >= 3){
            var value = 50000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.show();
      } else if(typeOfInsurancePolicyValue == "Accidental Death"  && classificationOfInsuredValue == "Member") {
        if (months < 3 && years < 1){
            var value = 2000.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 12000.00
          }
          else if (years >= 1 && years < 2){
           var value = 20000.00
          }
          else if (years >= 2 && years < 3){
            var value = 60000.00
          }
          else if (years >= 3){
            var value = 100000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.show();
      } else if(typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "Basic Life" && classificationOfInsuredValue == "Legal Dependent (Parent)" || typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Child)" ||typeOfInsurancePolicyValue == "TPD" && classificationOfInsuredValue == "Legal Dependent (Parent)"){
        if (months < 3 && years < 1){
            var value = 0.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 5000.00
          }
          else if (years >= 1 && years < 2){
           var value = 5000.00
          }
          else if (years >= 2 && years < 3){
            var value = 10000.00
          }
          else if (years >= 3){
            var value = 10000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.hide();
      } else if(typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "Accidental Death" && classificationOfInsuredValue == "Legal Dependent (Parent)") {
        if (months < 3 && years < 1){
            var value = 0.00
          }
          else if (months >= 3 && years < 1){ 
            var value = 5000.00
          }
          else if (years >= 1 && years < 2){
           var value = 5000.00
          }
          else if (years >= 2 && years < 3){
            var value = 10000.00
          }
          else if (years >= 3){
            var value = 10000.00
          }

        $('#face-amount').val(value);
        $returnedContributionField.hide();
      } else if(typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Spouse)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Child)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Legal Dependent (Parent)" || typeOfInsurancePolicyValue == "MVAH" && classificationOfInsuredValue == "Member") {
        var value = 0.00

        $('#face-amount').val(value);
      }
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
  claimsForm.init();
});
