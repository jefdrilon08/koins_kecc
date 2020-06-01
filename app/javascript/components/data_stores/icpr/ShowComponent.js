import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';
import Toggle from 'react-toggle';
import "react-toggle/style.css";

import SkCubeLoading from '../../SkCubeLoading';
import ErrorDisplay from '../../ErrorDisplay';
import {numberWithCommas} from '../../utils/helpers';

export default class ShowComponent extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false,
      errors: false,
      centers: [],
      currentOfficerId: "",
      currentCenterId: ""
    };
  }

  componentDidMount() {
    var context = this;

    $.ajax({
      url: "/api/v1/data_stores/icpr/fetch",
      method: 'GET',
      data: {
        id: this.props.id
      },
      success: function(response) {
        context.setState({
          isLoading: false,
          data: response.data
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching icpr");
      }
    });
  }

  renderMonths(o) {
    return  o.months.map(function(x) {
              return  <td key={o.id + '-month-' + x.month_index} className="text-right">
                        {numberWithCommas(x.amount)}
                      </td>
            });
  }

  renderRows() {
    var context = this;

    console.log(context.state.data);

    return  context.state.data.details.map(function(o, i) {
      console.log(o);
              return  <tr key={o.id}>
                        <td className="text-center">{i + 1}</td>
                        <td>
                          <a href={"/equity_accounts/" + o.member_account_id} target="_blank">
                            <strong>
                              {o.member_name}
                            </strong>
                          </a>
                        </td>
                        <td>
                          {o.identification_number}
                        </td>
                        <td>
                          {o.center.name}
                        </td>
                        {context.renderMonths(o)}
                        <td className="text-right">
                          {numberWithCommas(o.total_equity)} 
                        </td>
                        <td className="text-right">
                          {numberWithCommas(o.ave_equity)} 
                        </td>
                        <td className="text-right">
                          {numberWithCommas(o.equity_interest_amount)} 
                        </td>
                        <td className="text-right">
                          {numberWithCommas(o.savings_distribute)} 
                        </td>
                        <td className="text-right">
                          {numberWithCommas(o.cbu_distribute)}
                        </td>
                      </tr>
            });
  }

  render() {
    if(this.state.isLoading) {
      return <SkCubeLoading />;
    } else {
      return  (
        <div>
          <table className="table table-sm table-bordered table-responsive">
            <thead>
              <tr>
                <th>
                </th>
                <th>
                  Member
                </th>
                <th>
                  Identification Number
                </th>
                <th>
                  Center
                </th>
                <th className="text-right">
                  Jan
                </th>
                <th className="text-right">
                  Feb
                </th>
                <th className="text-right">
                  Mar
                </th>
                <th className="text-right">
                  Apr
                </th>
                <th className="text-right">
                  May
                </th>
                <th className="text-right">
                  Jun
                </th>
                <th className="text-right">
                  Jul
                </th>
                <th className="text-right">
                  Aug
                </th>
                <th className="text-right">
                  Sep
                </th>
                <th className="text-right">
                  Oct
                </th>
                <th className="text-right">
                  Nov
                </th>
                <th className="text-right">
                  Dec
                </th>
                <th className="text-right">
                  Total
                </th>
                <th className="text-right">
                  Average
                </th>
                <th className="text-right">
                  Equity Interest Amount
                </th>
                <th className="text-right">
                  Savings Distribute
                </th>
                <th className="text-right">
                  CBU Distribute
                </th>
              </tr>
            </thead>
            <tbody>
              {this.renderRows()}
              <tr>
                <th colSpan="18">
                  Total
                </th>
                <th className="text-right">
                  {numberWithCommas(this.state.data.total_equity_interest_amount)}
                </th>
                <th className="text-right">
                  {numberWithCommas(this.state.data.total_savings_distribute)}
                </th>
                <th className="text-right">
                  {numberWithCommas(this.state.data.total_cbu_distribute)}
                </th>
              </tr>
            </tbody>
          </table>
        </div>
      );
    }
  }
}
