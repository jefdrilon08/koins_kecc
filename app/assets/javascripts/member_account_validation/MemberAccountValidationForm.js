var MemberAccountValidationForm = (function() {
  var options;
  var authenticityToken;
  var $totalRf                         = $(".total-rf");
  var $total50PercentLif               = $(".total-50-percent-lif");
  var $totalEquityInterest             = $(".total-equity-interest");
  var $totalAdvanceLif                 = $(".total-advance-lif");
  var $totalAdvanceRf                  = $(".total-advance-rf");
  var $totalInterest                   = $(".total-interest");
  var $totalPolicyLoan                 = $(".total-policy-loan");
  var $grandTotal                      = $(".grand-total");
  
  var $section                         = $(".transaction-table");
  var $btnDelete                       = $(".btn-delete");
  var $memberSelect                    = $("#member-select");
  var $resignationDate                 = $("#resignation-date");
  var $btnAddMember                    = $("#btn-add-member");
  var $modalLoading                    = $("#modal-loading");
  var $modalMemberCancellation         = $("#modal-member-cancellation");
  var $btnConfirmMemberCancellation    = $("#btn-confirm-member-cancellation");
  var $inputDateCancelled              = $("#input-date-cancelled");
  var $inputReason                     = $("#input-reason");
  var $memberClassification            = $("#member-classification");

  var $message                        = $(".message");
  var templateErrorList               = $("#template-error-list").html();  

  // Hide controls
  //$(".modal-loading").find('.controls').hide();

  var urlDeletememberAccountValidationRecord    = "/api/v1/member_account_validations/delete_member_account_validation_record";
  var urlAddMember                              = "/api/v1/member_account_validations/add_member";
  var urlCancelValidation                       = "/api/v1/member_account_validations/cancel_member";

  var _bindEvents = function() {
    $btnAddMember.on("click", function() {
      // $modalLoading.modal("show");
      $btnAddMember.prop("disabled", true);
      $message.html("Loading...");

      var memberId = $memberSelect.val();
      var resignationDate = $resignationDate.val();
      var memberClassification = $memberClassification.val();

      $.ajax({
        url: urlAddMember,
        method: 'POST',
        dataType: 'json',
        data: {
          id: memberAccountValidationId,
          authenticity_token: authenticityToken,
          member_id: memberId,
          resignation_date: resignationDate,
          member_classification: memberClassification
        },
        success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.href = "/member_account_validations/" + memberAccountValidationId + "/edit";
        },
        error: function(response) {
          console.log(response);
          var errors  = [];
          try {
            errors  = JSON.parse(response.responseText).full_messages;
          } catch(err) {
            errors  = ["Something went wrong"];
            console.log(err);
          } finally {
            console.log(errors);
            $message.html(
              Mustache.render(
                templateErrorList,
                { errors: errors }
              )
            );
            $btnAddMember.prop("disabled", false);

            // $modalLoading.modal("hide");
          }
        }
      });
    });

    $btnDelete.on('click', function() {
      $btnDelete.prop("disabled", true);

      var $btn = $(this);
      var memberAccountValidationRecordId = $btn.data('member-account-validation-record-id');
      var deleteMemberId = $btn.data('delete-member-id');

      if (memberAccountValidationStatus == "cancelled"){
        $modalMemberCancellation.modal("show");
        $message.html("");

        $btnConfirmMemberCancellation.on("click", function() {
          $btnConfirmMemberCancellation.prop("disabled", true);

        $.ajax({
          url: urlCancelValidation,
          method: 'POST',
          dataType: 'json',
          data: {
            authenticity_token: authenticityToken,
            member_id: deleteMemberId,
            id: memberAccountValidationId,
            date_cancelled: $inputDateCancelled.val(),
            reason: $inputReason.val(),
            member_account_validation_record_id: memberAccountValidationRecordId,
          },
          success: function(response) {
            $message.html("Successfully created member account validation cancellation record");
            window.location.reload();
          },
          error: function(response) {
            alert(date_cancelled);
            console.log(response);
            var errors  = [];
            try {
              errors  = JSON.parse(response.responseText).full_messages;
            } catch(err) {
              errors  = ["Something went wrong"];
              console.log(err);
            } finally {
              console.log(errors);
              $message.html(
                Mustache.render(
                  templateErrorList,
                  { errors: errors }
                )
              );
            }
          }
        });

        $.ajax({
          url: urlDeletememberAccountValidationRecord,
          method: 'POST',
          dataType: 'json',
          data: { 
            authenticity_token: authenticityToken,
            member_account_validation_record_id: memberAccountValidationRecordId 
          },
          success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.reload();
          },
          error: function(response) {
            console.log(response);
            var errors  = [];
            try {
              errors  = JSON.parse(response.responseText).full_messages;
            } catch(err) {
              errors  = ["Something went wrong"];
              console.log(err);
            } finally {
              console.log(errors);
              $message.html(
                Mustache.render(
                  templateErrorList,
                  { errors: errors }
                )
              );

              $btnConfirmMemberCancellation.prop("disabled", false);
            }
          }
        });
      });
      }
      else{
        $.ajax({
          url: urlDeletememberAccountValidationRecord,
          method: 'POST',
          dataType: 'json',
          data: { 
            authenticity_token: authenticityToken,
            member_account_validation_record_id: memberAccountValidationRecordId 
          },
          success: function(response) {
          $message.html("Success! Redirecting...");
          window.location.reload();
          },
          error: function(response) {
            console.log(response);
            var errors  = [];
            try {
              errors  = JSON.parse(response.responseText).full_messages;
            } catch(err) {
              errors  = ["Something went wrong"];
              console.log(err);
            } finally {
              console.log(errors);
              $message.html(
                Mustache.render(
                  templateErrorList,
                  { errors: errors }
                )
              );

              $btnDelete.prop("disabled", false);
            }
          }
        });
       // end
       }
    });

    _computeTotalRf($section);
    _computeTotal50PercentLif($section);
    _computeTotalEquityInterest($section);
    _computeTotalAdvanceLif($section);
    _computeTotalAdvanceRf($section);
    _computeTotalInterest($section);
    _computeTotalPolicyLoan($section);
    _computeTotalAmt($section);
  }

  var _computeTotalRf = function($section) {
    var totalRf = 0.00;

    $.each($section.find(".rf"), function() {
      totalRf += parseFloat($(this).val());
    });

    $section.find(".total-rf").val(totalRf);
  }

  var _computeTotal50PercentLif = function($section) {
    var total50PercentLif = 0.00;

    $.each($section.find(".lif-50-percent"), function() {
      total50PercentLif += parseFloat($(this).val());
    });

    $section.find(".total-50-percent-lif").val(total50PercentLif);
  }

  var _computeTotalEquityInterest = function($section) {
    var totalEquityInterest = 0.00;

    $.each($section.find(".equity-interest"), function() {
      totalEquityInterest += parseFloat($(this).val());
    });

    $section.find(".total-equity-interest").val(totalEquityInterest);
  }

  var _computeTotalAdvanceLif = function($section) {
    var totalAdvanceLif = 0.00;

    $.each($section.find(".advance-lif"), function() {
      totalAdvanceLif += parseFloat($(this).val());
    });

    $section.find(".total-advance-lif").val(totalAdvanceLif);
  }

  var _computeTotalAdvanceRf = function($section) {
    var totalAdvanceRf = 0.00;

    $.each($section.find(".advance-rf"), function() {
      totalAdvanceRf += parseFloat($(this).val());
    });

    $section.find(".total-advance-rf").val(totalAdvanceRf);
  }

  var _computeTotalInterest = function($section) {
    var totalInterest = 0.00;

    $.each($section.find(".interest"), function() {
      totalInterest += parseFloat($(this).val());
    });

    $section.find(".total-interest").val(totalInterest);
  }

  var _computeTotalPolicyLoan = function($section) {
    var totalPolicyLoan = 0.00;

    $.each($section.find(".policy-loan"), function() {
      totalPolicyLoan += parseFloat($(this).val());
    });

    $section.find(".total-policy-loan").val(totalPolicyLoan);
  }

  var _computeTotalAmt = function($section) {
    var grandTotal = 0.00;

    $.each($section.find(".total-amount"), function() {
      grandTotal += parseFloat($(this).val());
    });

    $section.find(".grand-total").val(grandTotal);
  }

  var init = function(options) {
    authenticityToken = options.authenticityToken;
    memberAccountValidationId = options.memberAccountValidationId;
    memberAccountValidationStatus = options.memberAccountValidationStatus;
    deleteMemberId = options.deleteMemberId;
    memberAccountValidationRecordId = options.memberAccountValidationRecordId;

    _bindEvents();
  }

  return {
    init: init
  };
})();
