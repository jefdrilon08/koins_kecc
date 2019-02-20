import React from 'react';
import {numberWithCommas} from '../../utils/helpers';

export default class AgingOfReceivablesView extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
    }
  }

  renderDataRows() {
    var loans   = this.props.data.data.records;
    var rows    = [];
    var counter = 0;

    for(var i = 0; i < loans.length; i++) {
      var member      = loans[i].member;
      var center      = loans[i].center;
      var loanProduct = loans[i].loan_product;

      var dateReleased  = loans[i].date_released;

      var categoryAPastDueAmount  = 0.00;
      var categoryAParAmount      = 0.00;

      var categoryBPastDueAmount  = 0.00;
      var categoryBParAmount      = 0.00;

      var categoryCPastDueAmount  = 0.00;
      var categoryCParAmount      = 0.00;

      var numDaysPar  = parseInt(loans[i].num_days_par);

      if(numDaysPar >= 1 && numDaysPar <= 30) {
        categoryAPastDueAmount  = parseFloat(loans[i].principal_balance);
        categoryAParAmount      = parseFloat(loans[i].overall_principal_balance);
      } else if(numDaysPar >= 31 && numDaysPar <= 150) {
        categoryBPastDueAmount  = parseFloat(loans[i].principal_balance);
        categoryBParAmount      = parseFloat(loans[i].overall_principal_balance);
      } else if(numDaysPar >= 151) {
        categoryCPastDueAmount  = parseFloat(loans[i].principal_balance);
        categoryCParAmount      = parseFloat(loans[i].overall_principal_balance);
      }

      if(numDaysPar > 0) {
        counter++;

        rows.push(
          <tr key={"aor-" + loans[i].id}>
            <td className="text-center">
              {counter}
            </td>
            <td>
              <a href={"/loans/" + loans[i].id} target="_blank">
                <strong>
                  {member.last_name}, {member.first_name} {member.middle_name}
                  <br/>
                  <small className="text-muted">
                    PN: {loans[i].pn_number} Center: {center.name}
                  </small>
                </strong>
              </a>
            </td>
            <td>
              {loanProduct.name}
            </td>
            <td className="">
              {dateReleased}
            </td>
            <td className="text-right">
              {numberWithCommas(categoryAPastDueAmount)}
              <br/>
              {numberWithCommas(categoryAParAmount)}
            </td>
            <td className="text-right">
              {numberWithCommas(categoryBPastDueAmount)}
              <br/>
              {numberWithCommas(categoryBParAmount)}
            </td>
            <td className="text-right">
              {numberWithCommas(categoryCPastDueAmount)}
              <br/>
              {numberWithCommas(categoryCParAmount)}
            </td>
          </tr>
        );
      }
    }

    return rows;
  }

  render() {
    var data  = this.props.data;

    console.log("AoR Data:");
    console.log(data);

    return  (
      <div>
        <table className="table table-sm table-hover table-bordered" style={{fontSize: "0.8em"}}>
          <thead>
            <tr>
              <th className="text-center">
              </th>
              <th>
                Name
              </th>
              <th>
                Product
              </th>
              <th>
                Total
              </th>
              <th className="text-right">
                1-30
              </th>
              <th className="text-right">
                31-150
              </th>
              <th className="text-right">
                150 onwards
              </th>
            </tr>
          </thead>
          <tbody>
            {this.renderDataRows()}
          </tbody>
        </table>
      </div>
    );
  }
}
