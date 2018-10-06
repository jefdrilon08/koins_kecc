import React from 'react';

export default class GeneralLedgerComponent extends React.Component {
  constructor(props) {
    console.log("GeneralLedgerComponent");
    console.log(props);
    super(props);
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

  renderEntries() {
    var entries = this.props.data.entries;
    var items   = [];

    for(var i = 0; i < entries.length; i++) {
      items.push(
        <tr key={"item-" + entries[i].accounting_code_id + i}>
          <td width={"10%"}>
            <a href={"/accounting/accounting_entries/" + entries[i].accounting_entry_id}>
              {entries[i].reference_number}
            </a>
          </td>
          <td width={"60%"}>
            <small>
              {entries[i].particular}
            </small>
          </td>
          <td width={"10%"}>
            <center>
              <small>
                {entries[i].date_posted}
              </small>
            </center>
          </td>
          <td className="text-right" width={"10%"}>
            <strong>
              <small>
                {this.numberWithCommas(entries[i].net_amount)}
              </small>
            </strong>
          </td>
          <td className="text-right text-muted" width={"10%"}>
            {this.numberWithCommas(entries[i].running_balance)}
          </td>
        </tr>
      );
    }

    return items;
  }

  render() {
    return (
      <div>
        <table className="table table-bordered table-sm">
          <tr className="bg-info">
            <th colspan={4}>
              {this.props.data.accounting_code_name}
            </th>
            <th className="text-right">
              {this.numberWithCommas(this.props.data.beginning_balance)}
            </th>
          </tr>
          {this.renderEntries()}
          <tr className="bg-success">
            <th colspan={4}>
              Ending for {this.props.data.accounting_code_name}
            </th>
            <th className="text-right">
              {this.numberWithCommas(this.props.data.ending_balance)}
            </th>
          </tr>
        </table>
      </div>
    );
  }
}
