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

  render() {
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
          <table className="table table-sm">
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
