//= require_directory ./lib

Exports = (function() {
  var $branch = $("#select-branch");
  var $startDate = $("#filter-start-date");
  var $endDate = $("#filter-end-date");
  var $btnDownloadMember  = $("#export-member-segment-csv").find(".btn-download-members-csv");
  var $btnDownloadBeneficiary  = $("#export-member-segment-csv").find(".btn-download-beneficiaries-csv");
  var $btnDownloadDependent  = $("#export-member-segment-csv").find(".btn-download-dependents-csv");
  var $btnDownloadMemberAccount  = $("#export-transaction-segment-csv").find(".btn-download-member-accounts-csv");
  var $btnDownloadAccountTransaction  = $("#export-transaction-segment-csv").find(".btn-download-account-transactions-csv");

  var urlExportMember     = "/exports/members";
  var urlExportBeneficiary     = "/exports/beneficiaries";
  var urlExportLegalDependent     = "/exports/legal_dependents";
  var urlExportMemberAccount     = "/exports/member_accounts";
  var urlExportAccountTransaction     = "/exports/account_transactions";

  var init  = function() {
    $btnDownloadMember.on('click', function() {
      var params    = {
        start_date:  $startDate.val(),
        end_date:  $endDate.val(),
        branch: $branch.val()
      }

      window.location = urlExportMember + "?" + encodeQueryData(params);
    });

    $btnDownloadBeneficiary.on('click', function() {
      var params    = {
        start_date:  $startDate.val(),
        end_date:  $endDate.val(),
        branch: $branch.val()
      }

      window.location = urlExportBeneficiary + "?" + encodeQueryData(params);
    });

    $btnDownloadDependent.on('click', function() {
      var params    = {
        start_date:  $startDate.val(),
        end_date:  $endDate.val(),
        branch: $branch.val()
      }

      window.location = urlExportLegalDependent + "?" + encodeQueryData(params);
    });


    $btnDownloadMemberAccount.on('click', function() {
      var params    = {
        start_date:  $startDate.val(),
        end_date:  $endDate.val(),
        branch: $branch.val()
      }

      window.location = urlExportMemberAccount + "?" + encodeQueryData(params);
    });


    $btnDownloadAccountTransaction.on('click', function() {
      var params    = {
        start_date:  $startDate.val(),
        end_date:  $endDate.val(),
        branch: $branch.val()
      }

      window.location = urlExportAccountTransaction + "?" + encodeQueryData(params);
    });
  };

  return {
    init: init
  };
})();
