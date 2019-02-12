import React from 'react';
import $ from 'jquery';

import SkCubeLoading from '../SkCubeLoading';
import {numberWithCommas} from '../utils/helpers';
import MemberRecord from './MemberRecord';

export default class ShowUI extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false
    };
  }

  componentDidMount() {
    var id                = this.props.id;
    var authenticityToken = this.props.authenticityToken;
    var context           = this;

    $.ajax({
      url: "/api/v1/monthly_closing_collections/fetch",
      method: 'GET',
      data: {
        id: id
      },
      success: function(response) {
        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        alert("Error in fetching data");
      }
    });
  }

  render() {
    var context = this;

    if(context.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      console.log(context.state.data);

      var data          = context.state.data.data;
      var memberRecords = [];

      var totalInterest = 0.00;

      for(var i = 0; i < data.records.length; i++) {
        totalInterest += parseFloat(data.records[i].interest);

        memberRecords.push(
          <MemberRecord
            key={"member-record-" + i}
            data={data.records[i]}
          />
        );
      }

      return  (
        <div>
          {memberRecords}

          <table className="table table-bordered table-hover">
            <tbody>
              <tr>
                <th>
                  Total Interest:
                </th>
                <th className="text-right">
                  {numberWithCommas(totalInterest)}
                </th>
              </tr>
            </tbody>
          </table>
        </div>
      );
    }
  }
}
