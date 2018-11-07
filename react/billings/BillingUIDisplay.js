import React from 'react';
import $ from 'jquery';

import SkCubeLoading from '../SkCubeLoading';
import BillingUITable from './BillingUITable';
import {numberWithCommas} from '../utils/helpers';

export default class BillingUIDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false
    };
  }

  componentDidMount() {
    this.fetchBillingData();
  }

  fetchBillingData() {
    var context = this;

    $.ajax({
      url: "/api/v1/billings/fetch",
      method: 'GET',
      data: {
        id: this.props.id
      },
      success: function(response) {
        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching billing");
      }
    });
  }

  updateData(data) {
    this.setState({
      data: data
    });
  }

  render() {
    console.log(this.state.data);
    if(this.state.isLoading) {
      return (
        <div>
          <SkCubeLoading/>
        </div>
      );
    } else {
      return (
        <div>
          <table className="table table-sm table-bordered">
            <tbody>
              <tr>
                <th>
                  Expected Collections:
                </th>
                <td className="text-right">
                  <div className="text-muted">
                    {numberWithCommas(this.state.data.data.total_expected_collections)}
                  </div>
                </td>
              </tr>
              <tr>
                <th>
                  Total Collected:
                </th>
                <td className="text-right">
                  <strong>
                    {numberWithCommas(this.state.data.data.total_collected)}
                  </strong>
                </td>
              </tr>
            </tbody>
          </table>
          <hr/>
          <BillingUITable
            id={this.props.id}
            data={this.state.data}
            updateData={this.updateData.bind(this)}
            authenticityToken={this.props.authenticityToken}
          />
          <hr/>
        </div>
      );
    }
  }
}
