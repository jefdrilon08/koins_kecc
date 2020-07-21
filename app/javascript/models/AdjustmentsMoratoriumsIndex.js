var $modalNew;
var $selectBranch;
var $btnNew;
var $btnConfirmNew;

var init  = function() {
  _cacheDom();
  _bindEvents();
};

var _cacheDom = function() {
  $modalNew       = $("#modal-new");
  $selectBranch   = $("#select-branch");
  $btnNew         = $("#btn-new");
  $btnConfirmNew  = $("#btn-confirm-new");
};

var _bindEvents = function() {
};

export default { init: init };
