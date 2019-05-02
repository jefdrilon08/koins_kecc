var Seriatim = (function() {
  var $downloadBtn       = $("#download-btn");
  var $asOf              = $("#as-of");
  var $brachSelect       = $("#branch-select");
  var authenticityToken;

  var _bindEvents = function() {
    $downloadBtn.on('click', function() {
      data = {
        authenticity_token: authenticityToken,
        as_of: $asOf.val(),
        branch: $brachSelect.val(),
      };

      window.location = "/pages/seriatim_report?" + encodeQueryData(data);
    });
  };

  var init = function(config) {
    authenticityToken  = config.authenticityToken;

    _bindEvents();
  };

  return {
    init: init
  };
})();
