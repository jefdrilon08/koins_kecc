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
          <td width={"8%"}>
            <center>
              <small>
                {entries[i].date_posted}
              </small>
            </center>
          </td>
          <td width={"14%"}>
            <a href={"/accounting/accounting_entries/" + entries[i].accounting_entry_id} target={"_blank"}>
              {entries[i].reference_number}
            </a>
          </td>
          <td width={"10%"}>
            {entries[i].sub_reference_number}
          </td>
          <td width={"2%"}>
            {entries[i].book}
          </td>
          <td width={"50%"}>
            <small>
              {entries[i].particular}
            </small>
          </td>
          <td className="text-right" width={"8%"}>
            <small>
              {this.numberWithCommas(entries[i].dr_amount)}
            </small>
          </td>
          <td className="text-right" width={"8%"}>
            <small>
              {this.numberWithCommas(entries[i].cr_amount)}
            </small>
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
    var currentDrSum  = 0.00;
    var currentCrSum  = 0.00;
    var entries = this.props.data.entries;
    var items   = [];

    for(var i = 0; i < entries.length; i++) {
      currentDrSum += parseFloat(entries[i].dr_amount);
      currentCrSum += parseFloat(entries[i].cr_amount);
    }

    return (
      <div>
        <table className="table table-bordered table-sm">
          <thead>
            <tr className="bg-info">
              <th colspan={2}>
                {this.props.data.accounting_code_name}
              </th>
              <th className="">
                
              </th>
              <th className="">
                Book
              </th>
              <th>
              </th>
              <th className="text-right">
                Debit
              </th>
              <th className="text-right">
                Credit
              </th>
              <th className="text-right">
                {this.numberWithCommas(this.props.data.beginning_balance)}
              </th>
            </tr>
          </thead>
          <tbody>
            {this.renderEntries()}
          </tbody>
          <tfoot>
            <tr className="bg-success">
              <th colspan={5}>
                Ending for {this.props.data.accounting_code_name}
              </th>
              <th className="text-right">
                {this.numberWithCommas(currentDrSum)}
              </th>
              <th className="text-right">
                {this.numberWithCommas(currentCrSum)}
              </th>
              <th className="text-right">
                {this.numberWithCommas(this.props.data.ending_balance)}
              </th>
            </tr>
          </tfoot>
        </table>
      </div>
    );
  }
}
