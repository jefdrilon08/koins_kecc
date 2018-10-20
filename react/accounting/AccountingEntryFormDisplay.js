import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import DatePicker from 'react-datepicker';
import Select from 'react-select';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';
import ErrorDisplay from '../ErrorDisplay';
import moment from 'moment';

import 'react-datepicker/dist/react-datepicker.css';

import AccountingEntryPreview from './AccountingEntryPreview';

export default class AccountingEntryFormDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: false,
      id: props.id,
      book: props.book,
      referenceNumber: props.referenceNumber,
      branchId: props.branchId,
      branches: [],
      accountingCodes: [],
      accountingCodeId: "",
      accountingCodeObject: {},
      accountingCodeName: "",
      postType: "DR",
      amount: 0.00,
      balanced: false,
      message: "",
      errors: null,
      currentBranch: {
        value: "",
        label: ""
      },
      data: {
        book: "JVB",
        particular: "",
        branch_id: "",
        branch_name: "",
        reference_number: "",
        date_prepared: moment(),
        status: "pending",
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
    if(this.state.id) {
      this.fetchAccountingEntry();
    }

    this.fetchBranches();
    this.fetchAccountingCodes();
  }

  fetchAccountingEntry() {
    var context = this;

    $.ajax({
      url: "/api/v1/accounting_entries/fetch",
      method: "GET",
      data: {
        id: context.state.id
      },
      success: function(response) {
        console.log("Fetched accounting entry:");
        console.log(response);

        response.date_prepared = moment(response.date_prepared);

        context.setState({
          data: response,
          currentBranch: {
            value: response.branch_id,
            label: response.branch_name
          }
        });

        context.updateBalanced();
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching accounting entry");
      }
    });
  };

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

  save() {
    var context = this;
    var state   = context.state;

    var accounting_entry_data = state.data;

    this.setState({
      isLoading: true,
      message: "Loading..."
    });

    if(accounting_entry_data.journal_entries.length < 2) {
      alert("No journal entries");
      this.setState({
        isLoading: false,
        message: ""
      });
    } else {
      var temp_data = JSON.stringify({
        authenticity_token: context.props.authenticityToken,
        id: state.id,
        accounting_entry_data: {
          book: accounting_entry_data.book,
          branch_id: accounting_entry_data.branch_id,
          branch_name: accounting_entry_data.branch_name,
          date_prepared: accounting_entry_data.date_prepared.format("YYYY-MM-DD"),
          data: accounting_entry_data.data,
          journal_entries: accounting_entry_data.journal_entries,
          particular: accounting_entry_data.particular,
          reference_number: accounting_entry_data.reference_number
        }
      });

      console.log("temp_data:");
      console.log(temp_data);

      $.ajax({
        url: "/api/v1/accounting_entries/save",
        method: "POST",
        dataType: 'json',
        contentType: 'application/json',
        data: temp_data,
        success: function(response) {
          window.location.href = "/accounting/accounting_entries/" + response.id;
        },
        error: function(response) {
          alert("Error in saving accounting entry");
          context.setState({
            isLoading: false,
            message: "Error"
          });
        }
      });
    }
  }

  updateBalanced() {
    var debitAmount   = 0.00;
    var creditAmount  = 0.00;

    for(var i = 0; i < this.state.data.journal_entries.length; i++) {
      if(this.state.data.journal_entries[i].post_type == "DR") {
        debitAmount += parseFloat(this.state.data.journal_entries[i].amount);
      } else if(this.state.data.journal_entries[i].post_type == "CR") {
        creditAmount += parseFloat(this.state.data.journal_entries[i].amount);
      }
    }

    console.log("debitAmount: " + debitAmount);
    console.log("creditAmount: " + creditAmount);

    if(this.state.data.journal_entries.size == 0) {
      this.setState({
        balanced: false
      });

      return false;
    } else if(debitAmount != creditAmount) {
      this.setState({
        balanced: false
      });

      return false;
    } else {
      this.setState({
        balanced: true
      });

      return false;
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
    console.log("handleAccountingCodeChanged");
    console.log(o);

    var temp  = "";

    if(o) {
      temp = o.value;
    }

    this.setState({
      accountingCodeId: temp,
      accountingCodeName: o.label,
      accountingCodeObject: o
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

    var foundAccountingCode = false;

    var errors  = [];

    for(var i = 0; i < this.state.data.journal_entries.length; i++) {
      if(this.state.data.journal_entries[i].accounting_code_id == journal_entry.accounting_code_id) { 
        errors.push("Duplicate accounting code");
      }
    }

    // Check if accounting code is selected
    if(journal_entry.accounting_code_id == "") {
      errors.push("No accounting code specified");
    }

    // Check if amount is > 0
    if(journal_entry.amount <= 0) {
      errors.push("Invalid amount");
    }

    if(errors.length > 0) {
      alert("The following errors occurred:");
      for(var i = 0; i < errors.length; i++) {
        alert(errors[i]);
      }
    } else {
      // Add to journal entries
      var data  = this.state.data;

      data.journal_entries.push(journal_entry);

      this.setState({
        accountingCodeId: "",
        accountingCodeName: "",
        accountingCodeObject: {},
        postType: "DR",
        amount: 0.00,
        data: data
      });

    }

    this.updateBalanced();
  }

  handleRemoveClicked(index) {
    var data            = this.state.data;
    var journalEntries  = data.journal_entries;

    var newJournalEntries = [];

    for(var i = 0; i < journalEntries.length; i++) {
      if(i != index) {
        newJournalEntries.push(
          journalEntries[i]
        );
      }
    }

    data.journal_entries = newJournalEntries;

    this.setState({
      data: data
    });

    this.updateBalanced();
  }

  renderErrorDisplay() {
    var context = this;
    var state   = context.state;
    if(state.errors) {
      return  (
        <div className="row">
          <div className="col">
            <ErrorDisplay
              errors={state.errors}
            />
          </div>
        </div>
      );
    } else {
      return  (
        <div></div>
      );
    }
  };

  render() {
    var context = this;
    var state   = context.state;

    var data  = state.data;

    console.log(data);

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

    console.log("Current Branch: ");
    console.log(state.currentBranch);

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

    var currentAccountingCodeId = this.state.accountingCodeId;

    return (
      <div>
        <div className="row">
          <div className="col">
            <h6>
              Accounting Entry Form
            </h6>
          </div>
        </div>
        {this.renderErrorDisplay()}
        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>Date Prepared</label>
              <DatePicker
                className="form-control"
                selected={data.date_prepared}
                onChange={context.handleDatePreparedChanged.bind(this)}
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
                disabled={this.state.isLoading}
              >
                {bookOptions}
              </select>
            </div>
          </div>
          <div className="col">
            <div className="form-group">
              <label>Branch</label>
              <Select
                value={this.state.currentBranch}
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
            <textarea 
              className="form-control" 
              value={this.state.data.particular}
              onChange={this.handleParticularChanged.bind(this)} 
              disabled={this.state.isLoading}
            >
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
                value={this.state.accountingCodeObject}
                options={accountingCodeOptions}
                onChange={this.handleAccountingCodeChanged.bind(this)}
                disabled={this.state.isLoading}
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
                disabled={this.state.isLoading}
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
                disabled={this.state.isLoading}
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
          status={this.state.data.status}
          journalEntries={this.state.data.journal_entries}
          isLoading={this.state.isLoading}
          handleRemoveClicked={this.handleRemoveClicked.bind(this)}
        />

        <hr/>
        <div>
          {this.state.message}
        </div>
        <button
          className="btn btn-primary"
          onClick={this.save.bind(this)}
        >
          <span className="fa fa-check"/>
          Save
        </button>
        <a href="/" className="btn btn-danger">
          <span className="fa fa-times" />
          Cancel
        </a>
      </div>
    );
  }
}
