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
      officers: [],
      currentOfficerId: "",
      currentCenterId: "",
      currentLoanProductId: ""
    };
  }

  fetch(options) {
    var context       = this;
    var centerId      = options.centerId;

    var data  = {
      id: this.props.id,
      center_id: centerId
    }

    console.log("fetch (data):");
    console.log(data);

    this.setState({
      currentCenterId: centerId
    });

    $.ajax({
      url: "/api/v1/data_stores/watchlists/fetch",
      data: data,
      method: 'GET',
      success: function(response) {
        console.log(response);

        context.setState({
          isLoading: false,
          data: response
        });
      },
      error: function(response) {
        console.log(response);
        alert("Something went wrong when fetching data store");
      }
    });
  }

  componentDidMount() {
    var context = this;

    $.ajax({
      url: "/api/v1/data_stores/watchlists/fetch",
      data: {
        id: context.props.id
      },
      method: 'GET',
      success: function(response) {
        console.log(response);

        var centers       = response.data.centers;

        context.setState({
          isLoading: false,
          data: response,
          centers: centers
        });
      },
      error: function(response) {
        console.log(response);
        alert("Something went wrong when fetching data store");
      }
    });
  }

  renderErrorDisplay() {
    if(this.state.errors) {
      return  (
        <ErrorDisplay
          errors={this.state.errors}
        />
      );
    }
  }

  renderDataRows() {
    var rows      = [];
    var records   = this.state.data.data.records;

    for(var i = 0; i < records.length; i++) {
      rows.push(
        <tr key={"member-row-" + records[i].member.id}>
          <td className="text-center">
            {i+1}
          </td>
          <td>
            <strong>
              <a href={"/loans/" + records[i].id}>
                {records[i].member.last_name}, {records[i].member.first_name}
              </a>
            </strong>
          </td>
          <td>
            {records[i].center.name}
          </td>
          <td>
            {records[i].officer.last_name}, {records[i].officer.first_name}
          </td>
          <td>
            {records[i].loan_product.name}
          </td>
          <td className="text-right">
            {numberWithCommas(records[i].total_balance)}
          </td>
        </tr>
      );
    }

    return rows;
  }

  handleCenterChanged(event) {
    this.fetch({
      centerId: event.target.value,
      loanProductId: this.state.currentLoanProductId
    });
  }

  renderFilter() {
    var centerOptions   = [
       <option key={"center-select"} value="">
        -- SELECT --
      </option>
    ];

    for(var i = 0; i < this.state.centers.length; i++) {
      centerOptions.push(
        <option key={"center-" + i} value={this.state.centers[i].id}>
          {this.state.centers[i].name}
        </option>
      );
    }

    return  (
      <div className="row">
        <div className="col">
          <div className="form-group">
            <label>
              Center:
            </label>
            <select 
              value={this.state.currentCenterId} 
              onChange={this.handleCenterChanged.bind(this)} 
              className="form-control"
            >
              {centerOptions}
            </select>
          </div>
        </div>
      </div>
    );
  }

  render() {
    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      return  (
        <div>
          <table className="table table-sm table-bordered table-hover">
            <thead>
              <tr>
                <th>
                </th>
                <th>
                  Member
                </th>
                <th>
                  Center
                </th>
                <th>
                  Officer
                </th>
                <th>
                  Loan Product
                </th>
                <th className="text-right">
                  Past Due Amount
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
}
