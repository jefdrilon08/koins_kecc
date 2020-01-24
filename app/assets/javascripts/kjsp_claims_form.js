var kjspClaimsForm = (function() {

  var $yearLevel;

  var _cacheDom = function() {
    $yearLevel             = $("#year-level");
    $courseField           = $(".course-value");

 }

  var _bindEvents = function() {

      var yearLevelValue = ($yearLevel.val());

      if(yearLevelValue == "GRADE 7" || yearLevelValue == "GRADE 8" || yearLevelValue == "GRADE 9" || yearLevelValue == "GRADE 10" || yearLevelValue == "GRADE 11" || yearLevelValue == "GRADE 12")
        {
        $courseField.hide();
        }
      else{
        $courseField.show();  
      }

    $yearLevel.on('change', function() { 
      var yearLevelValue = ($yearLevel.val());

     if(yearLevelValue == "GRADE 7" || yearLevelValue == "GRADE 8" || yearLevelValue == "GRADE 9" || yearLevelValue == "GRADE 10" || yearLevelValue == "GRADE 11" || yearLevelValue == "GRADE 12")
        {
        $courseField.hide();
        }
      else{
        $courseField.show();  
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
  kjspClaimsForm.init();
});
