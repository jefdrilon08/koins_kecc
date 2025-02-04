import React from 'react';
import {numberWithCommas} from '../utils/helpers';

export default class AccountingEntryPreviewForFullPayment extends React.Component {
  constructor(props) {
    super(props);
  }

  accountingEntryContextColor() {
    if(this.props.book == "CRB") {
      return "bg-success";
    } else if(this.props.book == "CDB") {
      return "bg-warning";
    } else if(this.props.book == "JVB") {
      return "bg-info";
    } else {
      return "bg-info";
    }
  }

  renderCrbParameters() {
    if(this.props.book == "CRB") {
      return (
        <div>
          <hr/>
          <strong>
            OR Number: 
          </strong>
          <br/>
          <span className="text-muted">
            {this.props.data.or_number}
          </span>
          <br/>
          <strong>
            Service Invoice: 
          </strong>
          <br/>
          <span className="text-muted">
            {this.props.data.si_number}
          </span>
          <br/>
          <strong>
            AR Number: 
          </strong>
          <br/>
          <span className="text-muted">
            {this.props.data.ar_number}
          </span>
        </div>
      );
    }
  };

  renderCdbParameters() {
    console.log("CDB Parameters: ");
    console.log(this.props);
    if(this.props.book == "CDB") {
      return (
        <div className="row">
          <div className="col">
            <strong>
              Check Number:
            </strong>
            <div className="text-muted">
              {this.props.data.check_number}
            </div>
          </div>
          <div className="col">
            <strong>
              Check Voucher Number:
            </strong>
            <div className="text-muted">
              {this.props.data.check_voucher_number}
            </div>
          </div>
          <div className="col">
            <strong>
              Date of Check
            </strong>
            <div className="text-muted">
              {this.props.data.date_of_check}
            </div>
          </div>
        </div>
      );
    }
  };

  renderBalancedWarning() {
    var debitAmount   = 0.00;
    var creditAmount  = 0.00;

    for(var i = 0; i < this.props.journalEntries.length; i++) {
      if(this.props.journalEntries[i].post_type == "DR") {
        debitAmount += parseFloat(this.props.journalEntries[i].amount);
      } else if(this.props.journalEntries[i].post_type == "CR") {
        creditAmount += parseFloat(this.props.journalEntries[i].amount);
      }
    }

    if(!this.props.balanced) {
      return (
        <div className="callout callout-danger">
          <strong>
            Entries are not balanced.. Debit: {numberWithCommas(debitAmount)} Credit: {numberWithCommas(creditAmount)}
          </strong>
        </div>
      );
    }
  }

  render() {
    var context = this;
    var journalEntryRecords = [];


    // Debit entries
    for(var i = 0; i < this.props.journalEntries.length; i++) {
      if(this.props.journalEntries[i].post_type == "DR" && this.props.journalEntries[i].amount > 0) {
        var btnRemove = "";
        var btnEdit   = "";

        if(this.props.status == "pending") {
          btnRemove = <button 
                        className="btn btn-sm btn-danger"
                        onClick={context.props.handleRemoveClicked.bind(this, i)}
                      >
                        <span className="bi bi-x"/>
                      </button>;

          btnEdit = <button
                      className="btn btn-sm btn-info"
                      onClick={context.props.handleJournalEntryEdit.bind(this, i)}
                    >
                      <span className="bi bi-pencil"/>
                    </button>
        }

        journalEntryRecords.push(
          <tr key={"je-dr-" + i}>
            <td>
              {btnEdit}
              {btnRemove}
              {this.props.journalEntries[i].accounting_code_name}
            </td>
            <td className="text-end">
              {numberWithCommas(this.props.journalEntries[i].amount)}
            </td>
            <td className="text-end">
            </td>
          </tr>
        );
      }
    }

    // Credit entries
    for(var i = 0; i < this.props.journalEntries.length; i++) {
      if(this.props.journalEntries[i].post_type == "CR" && this.props.journalEntries[i].amount > 0) {
        var btnRemove = "";
        var btnEdit   = "";

        if(this.props.status == "pending") {
          btnRemove = <button 
                        className="btn btn-sm btn-danger"
                        onClick={context.props.handleRemoveClicked.bind(this, i)}
                      >
                        <span className="bi bi-x"/>
                      </button>;

          btnEdit = <button
                      className="btn btn-sm btn-info"
                      onClick={context.props.handleJournalEntryEdit.bind(this, i)}
                    >
                      <span className="bi bi-pencil"/>
                    </button>
        }

        journalEntryRecords.push(
          <tr key={"je-cr-" + i}>
            <td>
              {btnEdit}
              {btnRemove}
              {this.props.journalEntries[i].accounting_code_name}
            </td>
            <td className="text-end">
            </td>
            <td className="text-end">
              {numberWithCommas(this.props.journalEntries[i].amount)}
            </td>
          </tr>
        );
      }
    }

    return  (
      <div className="card border-danger">
        <div className={"card-header  bg-info" }>
          <div className="row">
            <div className="col-md-6">
              <strong>
              {this.props.book_for_fullpayment}
              </strong>
            </div>
            <div className="col-md-6">
              <div className="text-end">
                <div className="text-muted">
                  <span className="fa fa-store"/>
                  {this.props.branch}
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="card-body">
          {this.renderBalancedWarning()}
          <table className="table table-sm">
            <thead>
              <tr>
                <th width="50%">
                  Accounting Code
                </th>
                <th className="text-end" width="25%">
                  Debit
                </th>
                <th className="text-end" width="25%">
                  Credit
                </th>
              </tr>
            </thead>
            <tbody>
              {journalEntryRecords}
            </tbody>
          </table>
          <hr/>
          <div className="row">
            <div className="col">
              <label>
                Particular:
              </label>
              <p>
                {this.props.particular}
              </p>
            </div>
            <div className="col">
              <p className="text-end">
                <label>
                  <strong>
                    Approved By:
                  </strong>
                </label>
                <br/>
                {this.props.approved_by}
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
