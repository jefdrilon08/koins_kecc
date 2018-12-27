var FormResignation = (function() {
  var id;
  var authenticityToken;
  var resignationTypes;

  var $inputDateResigned;
  var $selectResignationType;
  var $selectResignationCode;
  var $displayResignationCodeVal;
  var $btnResign;

  var $message;
  var templateErrorList;

  var _updateResignationCodes = function() {
    var resignationType = $selectResignationType.val();

    $selectResignationCode.html("");

    for(var i = 0; i < resignationTypes.length; i++) {
      if(resignationTypes[i].name == resignationType) {
        for(var j = 0; j < resignationTypes[i].particulars.length; j++) {
          $selectResignationCode.append(
            "<option value='" + resignationTypes[i].particulars[j].code  + "'>" + resignationTypes[i].particulars[j].code + "</option>"
          );
        }
      }
    }
  }

  var _cacheDom = function() {
    $inputDateResigned          = $("#input-date-resigned");
    $selectResignationType      = $("#select-resignation-type");
    $selectResignationCode      = $("#select-resignation-code");
    $displayResignationCodeVal  = $("#display-resignation-code-val");
    $btnResign                  = $("#btn-resign");

    $message          = $(".message");
    templateErrorList = $("#template-error-list").html();
  };

  var _bindEvents = function() {
    $btnResign.on("click", function() {
      $message.html("Loading... Please wait...");

      $inputDateResigned.prop("disabled", true);
      $selectResignationType.prop("disabled", true);
      $selectResignationCode.prop("disabled", true);
      $btnResign.prop("disabled", true);
      $btnResign.hide();
    });

    _updateResignationCodes();

    $selectResignationType.on("change", function() {
      _updateResignationCodes();
    });
  };

  var init  = function(options) {
    id                = options.id;
    authenticityToken = options.authenticityToken;
    resignationTypes  = options.resignationTypes;

    console.log(resignationTypes);

    _cacheDom();
    _bindEvents();
  }

  return {
    init: init
  }
})();
