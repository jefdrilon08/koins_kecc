import React from 'react';

export default class AccountingEntryPreview extends React.Component {
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

  renderBalancedWarning() {
    if(!this.props.balanced) {
      return (
        <div className="callout callout-danger">
          <strong>
            Entries are not balanced...
          </strong>
        </div>
      );
    }
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

  render() {
    var context = this;
    var journalEntryRecords = [];


    // Debit entries
    for(var i = 0; i < this.props.journalEntries.length; i++) {
      if(this.props.journalEntries[i].post_type == "DR") {
        var btnRemove = "";
        if(this.props.status == "pending") {
          btnRemove = <button 
                        className="btn btn-sm btn-danger"
                        onClick={context.props.handleRemoveClicked.bind(this, i)}
                      >
                        <span className="fa fa-times"/>
                      </button>;
        }

        journalEntryRecords.push(
          <tr key={"je-dr-" + i}>
            <td>
              {btnRemove}
              {this.props.journalEntries[i].accounting_code_name}
            </td>
            <td className="text-right">
              {this.numberWithCommas(this.props.journalEntries[i].amount)}
            </td>
            <td className="text-right">
            </td>
          </tr>
        );
      }
    }

    // Credit entries
    for(var i = 0; i < this.props.journalEntries.length; i++) {
      if(this.props.journalEntries[i].post_type == "CR") {
        var btnRemove = "";
        if(this.props.status == "pending") {
          btnRemove = <button 
                        className="btn btn-sm btn-danger"
                        onClick={context.props.handleRemoveClicked.bind(this, i)}
                      >
                        <span className="fa fa-times"/>
                      </button>;
        }

        journalEntryRecords.push(
          <tr key={"je-cr-" + i}>
            <td>
              {btnRemove}
              {this.props.journalEntries[i].accounting_code_name}
            </td>
            <td className="text-right">
            </td>
            <td className="text-right">
              {this.numberWithCommas(this.props.journalEntries[i].amount)}
            </td>
          </tr>
        );
      }
    }

    return  (
      <div className="card border-danger">
        <div className={"card-header " + this.accountingEntryContextColor()}>
          <div className="row">
            <div className="col-md-6">
              <strong>
                [REFERENCE NUMBER] - {this.props.datePrepared}
              </strong>
            </div>
            <div className="col-md-6">
              <div className="text-right">
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
                <th className="text-right" width="25%">
                  Debit
                </th>
                <th className="text-right" width="25%">
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
              <p>
                {this.props.particular}
              </p>
            </div>
            <div className="col">
              <p className="text-right">
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
