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

  var urlExportMemberPerBranch = "/exports/members_per_branch_excel";
  var $btnDownloadMemberPerBranch = $("#export-member-per-branch-segment").find(".btn-download-member-per-branch");
  var urlExportMembersWithBeneficiaries = "/exports/members_with_beneficiaries_excel";
  var $btnDownloadMembersWithBenefeciaries = $("#export-members-with-beneficiaries-segment").find(".btn-download-members-with-beneficiaries");
  
  var encodeQueryData = function(data) {
    var ret = []
    for(var d in data) {
      ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
    }

    return ret.join("&");
  };

  var init  = function() {

    $btnDownloadMembersWithBenefeciaries.on('click', function() {
      var params    = {
        start_date:  $startDate.val(),
        end_date:  $endDate.val(),
        branch: $branch.val()
      }

      window.location = urlExportMembersWithBeneficiaries + "?" + encodeQueryData(params);
    });

    $btnDownloadMemberPerBranch.on('click', function() {
      var params    = {
        start_date:  $startDate.val(),
        end_date:  $endDate.val(),
        branch_id: $branch.val()
      }

      window.location = urlExportMemberPerBranch + "?" + encodeQueryData(params);
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

    $btnDownloadMember.on('click', function() {
      var params    = {
        start_date:  $startDate.val(),
        end_date:  $endDate.val(),
        branch: $branch.val()
      }

      window.location = urlExportMember + "?" + encodeQueryData(params);
    });

  };

  return {
    init: init
  };
})();
