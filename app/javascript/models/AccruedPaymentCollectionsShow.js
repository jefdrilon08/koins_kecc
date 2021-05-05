import Mustache from "mustache/mustache";
import 'select2';
import 'select2-theme-bootstrap4/dist/select2-bootstrap.css';

var $btnUpdateTransaction;
var $modalUpdateTransaction;
var $btnConfirmTransaction;


$btnUpdateTransaction         = $("#btn-update-transaction"); 
$modalUpdateTransaction       = $("#modal-update-transaction");
$btnConfirmTransaction        = $("#btn-confirm-transaction");

var _urlUpdateTransaction     = "/api/v1/accrued_payment_collections/update_transaction";


$btnUpdateTransaction.on("click", function(){
	//_memberDetails = $(this).data("id");
    $modalUpdateTransaction.modal("show");
});

export default { init: init };