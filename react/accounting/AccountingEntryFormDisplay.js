import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import DatePicker from 'react-datepicker';
import Select from 'react-select';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';
import moment from 'moment';

import 'react-datepicker/dist/react-datepicker.css';

import AccountingEntryPreview from './AccountingEntryPreview';

export default class AccountingEntryFormDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: false,
      book: props.book,
      referenceNumber: props.referenceNumber,
      branchId: props.branchId,
      branches: [],
      accountingCodes: [],
      accountingCodeId: "",
      accountingCodeName: "",
      postType: "DR",
      amount: 0.00,
      balanced: false,
      data: {
        book: "",
        particular: "",
        branch_id: "",
        branch_name: "",
        reference_number: "",
        date_prepared: moment(),
        data: {
          or_number: "",
          check_number: "",
          check_voucher_number: "",
          date_of_check: "",
          sub_reference_number: ""
        },
        journal_entries: []
      }
    };
  }

  componentDidMount() {
    this.fetchBranches();
    this.fetchAccountingCodes();
  }

  fetchAccountingCodes() {
    var context = this;

    $.ajax({
      url: "/api/v1/accounting_codes",
      method: "GET",
      data: {
        
      },
      dataType: 'json',
      success: function(response) {
        context.setState({
          accountingCodes: response.accounting_codes
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching accounting_codes");

        context.setState({
          accounting_codes: []
        });
      }
    });
  }

  fetchBranches() {
    var context = this;

    $.ajax({
      url: "/api/v1/branches",
      method: "GET",
      data: {
        
      },
      dataType: 'json',
      success: function(response) {
        context.setState({
          branches: response.branches
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching branches");

        context.setState({
          branches: []
        });
      }
    });
  }

  numberWithCommas(x) {
    x = (Math.round(x * 100) / 100).toFixed(2);

    if(x < 0) {
      x = x * -1; 
      x = "(" + x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + ")";
    } else {
      x = x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }   

    return x;

  }

  fetch() {
    var context = this;
    var state   = context.state;

    var book            = state.book;
    var referenceNumber = state.referenceNumber;
    var branchId        = state.branchId;

    if(this.props.accountingEntryId) {
      $.ajax({
        url: "/api/v1/accounting/accounting_entries/fetch",
        method: "GET",
        data: {
          book: book,
          reference_number: referenceNumber,
          branch_id: branchId
        },
        dataType: 'json',
        success: function(response) {
          console.log(response);
          var data  = response.data;
          
          context.setState({
            isLoading: false,
            data: data
          });
        },
        error: function(response) {
          context.setState({
            isLoading: false,
            data: false
          });
        }
      });
    } else {
      context.setState({
        isLoading: false
      });
    }
  }

  updateBalanced() {
    debitAmount   = 0.00;
    creditAmount  = 0.00;

    for(var i = 0; i < this.state.data.journal_entries; i++) {
      if(this.state.data.journal_entries[i].post_type == "DR") {
        debitAmount += parseFloat(this.state.data.journal_entries[i].amount);
      } else if(this.state.data.journal_entries[i].post_type == "CR") {
        creditAmount += parseFloat(this.state.data.journal_entries[i].amount);
      }
    }

    if(this.state.data.journal_entries.size == 0) {
      this.setState({
        balanced: false
      });
    } else if(debitAmount != creditAmount) {
      this.setState({
        balanced: false
      });
    } else {
      this.setState({
        balanced: true
      });
    }
  }

  handleSaveBtnClicked() {
    var context = this;
    
    context.setState({
      isLoading: true
    });
  }

  handleDatePreparedChanged(o) {
    var data  = this.state.data;

    data.date_prepared  = o

    this.setState({
      data: data
    });
  }

  handleBranchChanged(o) {
    var temp  = "";

    if(o) {
      temp = o.value;
    }

    var data  = this.state.data;

    data.branch_id    = temp;
    data.branch_name  = o.label;

    this.setState({
      data: data
    });
  }

  handleAccountingCodeChanged(o) {
    var temp  = "";

    if(o) {
      temp = o.value;
    }

    this.setState({
      accountingCodeId: temp,
      accountingCodeName: o.label
    });
  }

  handleBookChanged(event) {
    var data  = this.state.data;
    data.book = event.target.value;

    this.setState({
      data: data
    });
  }

  handleParticularChanged(event) {
    var data        = this.state.data;
    data.particular = event.target.value;

    this.setState({
      data: data
    });
  }

  handlePostTypeChanged(event) {
    this.setState({
      postType: event.target.value
    });
  }

  handleAmountChanged(event) {
    this.setState({
      amount: event.target.value
    });
  }

  handleAddJournalEntryClicked() {
    var journal_entry = {
      id: "",
      accounting_code_id: this.state.accountingCodeId,
      accounting_code_name: this.state.accountingCodeName,
      post_type: this.state.postType,
      amount: this.state.amount
    }

    console.log(journal_entry);

    var foundAccountingCode = false;

    var errors  = [];

    for(var i = 0; i < this.state.data.journal_entries.length; i++) {
      if(this.state.data.journal_entries[i].accounting_code_id == journal_entry.accounting_code_id) { 
        errors.push("Duplicate accounting code");
      }
    }

    // Check if accounting code is selected
    if(journal_entry.accounting_code_id) {
      errors.push("No accounting code specified");
    } else if(foundAccountingCode) {
      // Check if we have same accounting code and post type
    }

    // Check if amount is > 0
    if(journal_entry.amount && journal_entry.amount <= 0) {
      errors.push("Invalid amount");
    }

    if(errors.length > 0) {
      alert("The following errors occurred:");
      for(var i = 0; i < errors.length; i++) {
        alert(errors[i]);
      }
    } else {
      this.setState({
        accountingCodeId: "",
        accountingCodeName: "",
        postType: "DR",
        amount: 0.00
      });
    }
  }

  render() {
    var context = this;
    var state   = context.state;

    var data  = state.data;

    var branchOptions = [];

    for(var i = 0; i < state.branches.length; i++) {
      branchOptions.push({
        value: state.branches[i].id,
        label: state.branches[i].name
      });
    }

    var accountingCodeOptions = [];

    for(var i = 0; i < state.accountingCodes.length; i++) {
      accountingCodeOptions.push({
        value: state.accountingCodes[i].id,
        label: state.accountingCodes[i].name
      });
    }

    var bookOptions = [
      <option value={"JVB"}>
        Journal Voucher
      </option>,
      <option value={"CRB"}>
        Cash Receipts
      </option>,
      <option value={"CDB"}>
        Cash Disbursement
      </option>,
      <option value={"MISC"}>
        Miscellaneous
      </option>
    ];

    return (
      <div>
        <div className="row">
          <div className="col">
            <h6>
              Accounting Entry Form
            </h6>
          </div>
        </div>
        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>Date Prepared</label>
              <DatePicker
                className="form-control"
                selected={data.date_prepared}
                onChange={context.handleDatePreparedChanged.bind(this)}
                disabled={state.isLoading}
              />
            </div>
          </div>
          <div className="col">
            <div className="form-group">
              <label>Book</label>
              <select 
                className="form-control" 
                value={data.book} 
                onChange={this.handleBookChanged.bind(this)}
              >
                {bookOptions}
              </select>
            </div>
          </div>
          <div className="col">
            <div className="form-group">
              <label>Branch</label>
              <Select
                value={data.branchId}
                options={branchOptions}
                onChange={this.handleBranchChanged.bind(this)}
                disabled={state.isLoading}
              />
              <br/>
            </div>
          </div>
        </div>
        <div className="row">
          <div className="col">
            <label>Particular</label>
            <textarea className="form-control" onChange={this.handleParticularChanged.bind(this)}>
            </textarea>
          </div>
        </div>
        <hr/>
        <h6>Add Journal Entry</h6>
        <div className="row">
          <div className="col-md-6"> 
            <div className="form-group">
              <label>Accounting Code</label>
              <Select
                value={state.accountingCodeId}
                options={accountingCodeOptions}
                onChange={this.handleAccountingCodeChanged.bind(this)}
                disabled={state.isLoading}
              />
            </div>
          </div>
          <div className="col-md-2"> 
            <div className="form-group">
              <label>Post Type</label>
              <select 
                className="form-control" 
                value={state.postType} 
                onChange={this.handlePostTypeChanged.bind(this)}
              >
                <option value={"DR"}>
                  Debit
                </option>
                <option value={"CR"}>
                  Credit
                </option>
              </select>
            </div>
          </div>
          <div className="col-md-2"> 
            <div className="form-group">
              <label>Amount</label>
              <input
                type="number"
                className="form-control"
                value={this.state.amount}
                onChange={this.handleAmountChanged.bind(this)}
              />
            </div>
          </div>
          <div className="col-md-2"> 
            <div className="form-group">
              <label>Actions</label>
              <button
                className="btn btn-info btn-block"
                onClick={this.handleAddJournalEntryClicked.bind(this)}
              >
                <span className="fa fa-plus"/>
                Add
              </button>
            </div>
          </div>
        </div>
        <hr/>
        <h6>
          Accounting Entry Preview
        </h6>
        <AccountingEntryPreview
          book={data.book}
          particular={data.particular}
          datePrepared={data.date_prepared.format("YYYY-MM-DD")}
          branch={data.branch_name}
          balanced={this.state.balanced}
        />
      </div>
    );
  }
}
