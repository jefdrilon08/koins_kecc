import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';

import SkCubeLoading from '../SkCubeLoading';
import ErrorDisplay from '../ErrorDisplay';

import AccountingEntryPreview from '../accounting/AccountingEntryPreview';
import AccountingEntryPreviewForFullPayment from'../accounting/AccountingEntryPreviewForFullPayment';

export default class AccountingEntryComponent extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false,
      errors: false
    };
  }

  componentDidMount() {
    var context = this;

    var data  = {
      id: this.props.id,
      member_id: this.props.memberId
    }

    $.ajax({
      url: "/api/v1/loans/fetch",
      data: data,
      method: 'GET',
      success: function(response) {
        console.log(response);
        context.setState({
          isLoading: false,
          data: response.loan,
          accountingCodes: response.accounting_codes
        });
      },
      error: function(response) {
        console.log(response);
        alert("Something went wrong when fetching loan");
      }
    });
  }

  handleAccountingCodeClick(entry) {
    console.log("Clicked Entry:", entry);
    alert(`You clicked on ${entry.accounting_code_name} with amount ${entry.amount}`);
  }  

  renderErrorDisplay() {
    if(this.state.errors) {
      return  (
        <ErrorDisplay
          errors={this.state.errors}
        />
      );
    }
  }

  handleRemoveClicked() {
  }

  render() {
    if (this.state.isLoading) {
      return (
        <SkCubeLoading />
      );
    } else {
      console.log("this.state.data:");
      console.log(this.state.data);
      var accounting_entry_data = this.state.data?.data?.accounting_entry || null;
      var for_full_payment_entries = this.state.data?.data?.for_full_payment_entries || null;
      var for_full_payment = this.state.data?.data?.for_full_payment?.reference_number || null;
      var for_full_paymentapproved = this.state.data?.data?.accounting_entry?.approved_by || null;
      var approved_by_fullpayment = this.state.data?.data?.for_full_payment?.approved_by || null;

      console.log(approved_by_fullpayment);



          // Extract voucher data from state
      var voucherData = this.state.data.data.voucher || {};

      var member = this.state.data.data.member || {};
      var first_name = member.first_name || "";
      var middle_name = member.middle_name || "";
      var last_name = member.last_name || "";

    

      // Get the check numbers
      var bankCheckNumber = voucherData.bank_check_number || "";
      var checkNumber = voucherData.check_number || "";


      
    

      
      // var debitAmount = for_full_payment_entries.debit_journal_entries[0].amount;
      // var accounting_amount = accounting_entry_data.journal_entries[3].amount;

      // var net_amount = accounting_amount - debitAmount;
      
      // console.log(debitAmount);
      // console.log(accounting_amount);
      // console.log(net_amount);

      console.log(this.state.data);
      
    

      // Check if for_full_payment_entries has valid data
      const hasFullPaymentEntries = for_full_payment_entries && Object.keys(for_full_payment_entries).length > 0;
  
      return (
        <div>
          {/* Accounting Entry Preview for the regular accounting entry */}
          <AccountingEntryPreview
            id={this.state.data.id}
            loanstatus={this.state.data.status}
            book={accounting_entry_data.book}
            particular={accounting_entry_data.particular}
            datePrepared={accounting_entry_data.date_prepared}
            referenceNumber={accounting_entry_data.reference_number}
            approved_by={accounting_entry_data.approved_by}
            branch={accounting_entry_data.branch_name}
            balanced={true}
            status={accounting_entry_data.status}
            journalEntries={accounting_entry_data.journal_entries}
            isLoading={this.state.isLoading}
            handleRemoveClicked={this.handleRemoveClicked.bind(this)}
            data={accounting_entry_data.data}
            handleEntryClick={this.handleAccountingCodeClick.bind(this)}
            accountingCodes={this.state.accountingCodes}
          />
          
          {/* Only render AccountingEntryPreviewForFullPayment if there are full payment entries */}
          {hasFullPaymentEntries && (
            <AccountingEntryPreviewForFullPayment
              book_for_fullpayment={for_full_payment_entries.book}
              particular_for_fullpayment={for_full_payment_entries.particular}
              approved_by_for_full_payment={for_full_payment_entries.prepared_by}
              journalEntryRecordsforfullpayment={for_full_payment_entries.journal_entries} 
              branch_for_full_payment={for_full_payment_entries.branch_name}
              check_number_ck = {bankCheckNumber}
              check_number_cv = {checkNumber}
              first_name = {first_name}
              middle_name = {middle_name}
              last_name = {last_name}
              ref_number_forfullpayment = {for_full_payment}
              approved_by_full = {approved_by_fullpayment}

            />
          )}
        </div>
      );
    }
  }
}
