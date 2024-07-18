import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import Select from 'react-select';

import SkCubeLoading from '../SkCubeLoading';
import ErrorDisplay from '../ErrorDisplay';

import AccountingEntryPreview from './AccountingEntryPreview';
import Modal from 'react-modal';
import {numberWithCommas} from '../utils/helpers'; 
import {customStyles} from '../utils/consts';

export default class AccountingEntryFormComponent extends React.Component {
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
      accountingFunds: [],
      accountingCodeId: "",
      accountingFundId: props.accountingFundId,
      accountingCodeObject: {},
      accountingCodeName: "",
      postType: "DR",
      amount: 0.00,
      balanced: false,
      message: "",
      errors: null,
      modalEditIsOpen: false,
      currentBranch: {
        value: "",
        label: ""
      },
      journalEntry: {
        index: "",
        accounting_code_name: "",
        accounting_code_id: "",
        post_type: "",
        amount: 0.00
      },
      data: {
        book: "JVB",
        particular: "",
        branch_id: "",
        branch_name: "",
        reference_number: "",
        date_prepared: (new Date()),
        status: "pending",
        accounting_fund_id: props.accountingFundId,
        data: {
          or_number: "",
          check_number: "",
          check_voucher_number: "",
          date_of_check: "",
          sub_reference_number: "",
          payee: ""
        },
        journal_entries: []
      }
    };
  }

  componentDidMount() {
    this.fetchAccountingEntry();
    this.fetchBranches();
    this.fetchAccountingCodes();
    this.fetchAccountingFunds();
  }

  fetchAccountingFunds() {
    var context = this;

    $.ajax({
      url: "/api/v1/accounting_funds",
      method: "GET",
      data: {
        
      },
      dataType: 'json',
      success: function(response) {
        // Set currentAccountingFundId
        var data  = context.state.data;
        
        if(response.accounting_funds.length > 0) {
          data.accounting_fund_id = response.accounting_funds[0].id;  
        }

        context.setState({
          accountingFunds: response.accounting_funds,
          data: data
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching accounting_funds");

        context.setState({
          accountingFunds: []
        });
      }
    });
  }

  fetchAccountingEntry() {
    var context = this;

    $.ajax({
      url: "/api/v1/accounting_entries/fetch",
      method: "GET",
      data: {
        id: context.state.id,
        book: context.state.book
      },
      success: function(response) {
        console.log("Fetched accounting entry:");
        console.log(response);

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
        var tempCurrentBranch = {
          value: "",
          label: ""
        }

        if(response.branches.length > 0) {
          console.log("DEFAULT BRANCH:");
          console.log(context.props.defaultBranch);
          if(context.props.defaultBranch) {
            tempCurrentBranch = context.props.defaultBranch;
          } else {
            tempCurrentBranch = {
              value: response.branches[0].id,
              label: response.branches[0].name
            };
          }

          console.log("TEMP CURRENT BRANCH");
          console.log(tempCurrentBranch);

          context.setState({
            branches: response.branches,
            currentBranch: tempCurrentBranch
          });
        } else {
          context.setState({
            branches: response.branches
          });
        }
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

  handleDateOfCheckChanged(o) {
    var data  = this.state.data;

    if(o) {
      data.data.date_of_check = o.target.value;

      this.setState({
        data: data
      });
    }
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
          date_prepared: accounting_entry_data.date_prepared,
          data: accounting_entry_data.data,
          journal_entries: accounting_entry_data.journal_entries,
          particular: accounting_entry_data.particular,
          reference_number: accounting_entry_data.reference_number,
          accounting_fund_id: accounting_entry_data.accounting_fund_id
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
          console.log(response);

          var errors  = JSON.parse(response.responseText).errors;
          context.setState({
            isLoading: false,
            message: "Error",
            errors: errors
          });
        }
      });
    }
  }

  handleJournalEntryEdit(index) {
    var journalEntries  = this.state.data.journal_entries;

    var accounting_code_id  = journalEntries[index].accounting_code_id;
    var post_type           = journalEntries[index].post_type;
    var amount              = journalEntries[index].amount;
    var name                = journalEntries[index].name;

    var journalEntry  = this.state.journalEntry;

    journalEntry.index              = index;
    journalEntry.accounting_code_id = accounting_code_id;
    journalEntry.post_type          = post_type;
    journalEntry.amount             = amount;
    journalEntry.name               = name;

    this.setState({
      modalEditIsOpen: true,
      journalEntry: journalEntry
    });
  }

  handleJournalEntryPostTypeChanged(event) {
    var journalEntry        = this.state.journalEntry;
    journalEntry.post_type  = event.target.value;

    this.setState({
      journalEntry: journalEntry
    });
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

    debitAmount   = parseFloat(numberWithCommas(debitAmount));
    creditAmount  = parseFloat(numberWithCommas(creditAmount));

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

    data.date_prepared = o.target.value;

    this.setState({
      data: data
    });
  }

  handleBranchChanged(o) {
    console.log("handleBranchChanged:");
    console.log(o);
    var temp  = "";

    if(o) {
      temp = o.value;
    }

    var data  = this.state.data;

    data.branch_id    = temp;
    data.branch_name  = o.label;

    this.setState({
      data: data,
      currentBranch: o
    });
  }

  handleAccountingCodeChanged(o) {
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

  handleAccountingFundChanged(event) {
    var data                = this.state.data;
    data.accounting_fund_id = event.target.value;

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
      if(this.state.data.journal_entries[i].accounting_code_id == journal_entry.accounting_code_id && this.state.data.journal_entries[i].post_type == journal_entry.post_type) { 
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

  handleOrNumberChanged(event) {
    var data            = this.state.data;
    data.data.or_number = event.target.value;

    this.setState({
      data: data
    });
  };

  handleArNumberChanged(event) {
    var data            = this.state.data;
    data.data.ar_number = event.target.value;

    this.setState({
      data: data
    });
  };
  handleSiNumberChanged(event) {
    var data            = this.state.data;
    data.data.si_number = event.target.value;

    this.setState({
      data: data
    });
  };
  handlePayeeChanged(event) {
    var data        = this.state.data;
    data.data.payee = event.target.value.toUpperCase();

    this.setState({
      data: data
    });
  };

  handleCheckNumberChanged(event) {
    var data                = this.state.data;
    data.data.check_number  = event.target.value;

    this.setState({
      data: data
    });
  };

  handleCheckVoucherNumberChanged(event) {
    var data                        = this.state.data;
    data.data.check_voucher_number  = event.target.value;

    this.setState({
      data: data
    });
  };

  renderDataParameters() {
    var accountingEntryData = this.state.data;
    var state               = this.state;

    if(accountingEntryData.book == "CRB") {
      return  (
        <div>
          <hr/>
          <h6>
            Cash Receipt Parameters
          </h6>
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>
                  OR Number
                </label>
                <input 
                  type="text" 
                  value={accountingEntryData.data.or_number}
                  onChange={this.handleOrNumberChanged.bind(this)} 
                  className="form-control" 
                  disabled={this.state.isLoading}
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>
                  AR Number
                </label>
                <input 
                  type="text" 
                  value={accountingEntryData.data.ar_number}
                  onChange={this.handleArNumberChanged.bind(this)} 
                  className="form-control" 
                  disabled={this.state.isLoading}
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>
                  SI Number
                </label>
                <input 
                  type="text" 
                  value={accountingEntryData.data.si_number}
                  onChange={this.handleSiNumberChanged.bind(this)} 
                  className="form-control" 
                  disabled={this.state.isLoading}
                />
              </div>
            </div>
          </div>
        </div>
      );
    } else if(accountingEntryData.book == "CDB") {
      var dateOfCheck = new Date();

      if(accountingEntryData && accountingEntryData.data.date_of_check) {
        dateOfCheck = accountingEntryData.data.date_of_check;
      }

      return  (
        <div>
          <hr/>
          <h6>
            Cash Disbursement Parameters
          </h6>
          <div className="row">
            <div className="col-md-4">
              <div className="form-group">
                <label>
                  Check Number
                </label>
                <input 
                  type="text" 
                  value={accountingEntryData.data.check_number}
                  onChange={this.handleCheckNumberChanged.bind(this)} 
                  className="form-control" 
                  disabled={state.isLoading}
                />
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group">
                <label>
                  Check Voucher Number
                </label>
                <input 
                  type="text" 
                  value={accountingEntryData.data.check_voucher_number}
                  onChange={this.handleCheckVoucherNumberChanged.bind(this)} 
                  className="form-control" 
                  disabled={this.state.isLoading}
                />
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group">
                <label>Date of Check</label>
                <input
                  className="form-control"
                  value={dateOfCheck}
                  onChange={this.handleDateOfCheckChanged.bind(this)}
                  type="date"
                  disabled={state.isLoading}
                />
              </div>
            </div>
          </div>
        </div>
      );
    }
  };

  handleJournalEntryAccountingCodeChanged(o) {
    var journalEntry                  = this.state.journalEntry;
    journalEntry.accounting_code_id   = o.value;
    journalEntry.accounting_code_name = o.label;

    this.setState({
      journalEntry: journalEntry
    });
  }

  handleJournalEntryAmountChanged(event) {
    var journalEntry    = this.state.journalEntry;
    journalEntry.amount = event.target.value;

    this.setState({
      journalEntry: journalEntry
    });
  }
  
  handleCancelJournalEntryClicked() {
    this.setState({
      modalEditIsOpen: false
    })
  }

  handleSaveJournalEntryClicked() {
    var journalEntry    = this.state.journalEntry;
    var index           = journalEntry.index;
    var data            = this.state.data;

    console.log(journalEntry);

    data.journal_entries[index].accounting_code_id    = journalEntry.accounting_code_id;
    data.journal_entries[index].accounting_code_name  = journalEntry.accounting_code_name;
    data.journal_entries[index].post_type             = journalEntry.post_type;
    data.journal_entries[index].amount                = journalEntry.amount;

    console.log("handleSaveJournalEntryClicked:");
    console.log(data.journal_entries[index]);
    console.log("---handleSaveJournalEntryClicked");

    this.setState({
      modalEditIsOpen: false,
      data: data
    })

    this.updateBalanced();
  }

  renderModalEditContent() {
    var state                 = this.state;
    var journalEntry          = state.journalEntry;
    var accountingCodeOptions = [];

    var currentAccountingCode = {
      value: "",
      label: ""
    }

    for(var i = 0; i < state.accountingCodes.length; i++) {
      if(journalEntry.accounting_code_id == state.accountingCodes[i].id) {
        currentAccountingCode = {
          value: state.accountingCodes[i].id,
          label: state.accountingCodes[i].name
        }
      }

      accountingCodeOptions.push({
        value: state.accountingCodes[i].id,
        label: state.accountingCodes[i].name
      });
    }

    return  (
      <div className="container-fluid">
        <h3>
          Edit Journal Entry
        </h3>
        <hr/>
        <div className="row">
          <div className="col-md-6">
            <div className="form-group">
              <label>
                Accounting Code
              </label>
              <Select
                value={currentAccountingCode}
                options={accountingCodeOptions}
                onChange={this.handleJournalEntryAccountingCodeChanged.bind(this)}
                disabled={this.state.isLoading}
              />
            </div>
          </div>
          <div className="col-3">
            <div className="form-group">
              <label>
                Post Type
              </label>
              <select
                className="form-control"
                value={journalEntry.post_type}
                onChange={this.handleJournalEntryPostTypeChanged.bind(this)}
              >
                <option value="DR">
                  Debit
                </option>
                <option value="CR">
                  Credit
                </option>
              </select>
            </div>
          </div>
          <div className="col-3">
            <div className="form-group">
              <label>
                Amount
              </label>
              <input
                type="number"
                value={journalEntry.amount}
                className="form-control"
                onChange={this.handleJournalEntryAmountChanged.bind(this)}
              />
            </div>
          </div>
        </div>
        <hr/>
        <center>
          <div className="btn-group">
            <button
              className="btn btn-primary"
              onClick={this.handleSaveJournalEntryClicked.bind(this)}
            >
              <span className="bi bi-check"/>
              Update
            </button>
            <button 
              className="btn btn-danger"
              onClick={this.handleCancelJournalEntryClicked.bind(this)}
            >
              <span className="bi bi-x"/>
              Cancel
            </button>
          </div>
        </center>
        <hr/>
      </div>
    );
  }

  render() {
    var context               = this;
    var state                 = context.state;
    var data                  = state.data;
    var branchOptions         = [];
    var accountingCodeOptions = [];
    var accountingFundOptions = [];

    console.log("DATA:");
    console.log(data);

    console.log(state.branches);

    for(var i = 0; i < state.branches.length; i++) {
      branchOptions.push({
        value: state.branches[i].id,
        label: state.branches[i].name
      });
    }

    console.log("branchOptions:");
    console.log(branchOptions);

    for(var i = 0; i < state.accountingCodes.length; i++) {
      accountingCodeOptions.push({
        value: state.accountingCodes[i].id,
        label: state.accountingCodes[i].name
      });
    }

    // Build accountingFundOptions as <option> tags
    for(var i = 0; i < state.accountingFunds.length; i++) {
      accountingFundOptions.push(
        <option value={state.accountingFunds[i].id} key={"accounting-fund-" + state.accountingFunds[i].id}>
          {state.accountingFunds[i].name}
        </option>
      );
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

    var currentAccountingCodeId = this.state.accountingCodeId;

    console.log("CURRENT BRANCH IN RENDER");
    console.log(this.state.currentBranch);
    var tempCurrentBranch = {
      value: this.state.currentBranch.value,
      label: this.state.currentBranch.label
    };

    return (
      <div>
        <Modal
          isOpen={this.state.modalEditIsOpen}
          style={customStyles}
        >
          {this.renderModalEditContent()}
        </Modal>
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
              <br/>
              <input
                className="form-control"
                value={data.date_prepared}
                type="date"
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
                value={tempCurrentBranch}
                options={branchOptions}
                onChange={this.handleBranchChanged.bind(this)}
                disabled={state.isLoading}
              />
              <br/>
            </div>
          </div>
          <div className="col">
            <div className="form-group">
              <label>Payee</label>
              <input
                value={this.state.data.data.payee}
                onChange={this.handlePayeeChanged.bind(this)}
                disabled={state.isLoading}
                className="form-control"
              />
              <br/>
            </div>
          </div>
        </div>
        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>Accounting Fund</label>
              <select
                value={data.accounting_fund_id}
                className="form-control"
                onChange={this.handleAccountingFundChanged.bind(this)}
              >
                {accountingFundOptions}
              </select>
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
        {this.renderDataParameters()}
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
              <div className="form-group">
                <div className="btn-group">
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
          </div>
        </div>
        <hr/>
        <h6>
          Accounting Entry Preview
        </h6>
        <AccountingEntryPreview
          book={data.book}
          particular={data.particular}
          datePrepared={data.date_prepared}
          branch={data.branch_name}
          balanced={this.state.balanced}
          status={this.state.data.status}
          journalEntries={this.state.data.journal_entries}
          isLoading={this.state.isLoading}
          handleRemoveClicked={this.handleRemoveClicked.bind(this)}
          handleJournalEntryEdit={this.handleJournalEntryEdit.bind(this)}
          data={this.state.data.data}
        />

        <hr/>
        <div>
          {this.state.message}
        </div>
        <div className="btn-group">
          <button
            className="btn btn-primary"
            onClick={this.save.bind(this)}
          >
            <span className="bi bi-check"/>
            Save
          </button>
          <a href={"/accounting/books/" + data.book.toLowerCase()} className="btn btn-danger">
            <span className="bi bi-x" />
            Cancel
          </a>
        </div>
      </div>
    );
  }
}
