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
      errors: false
    };
  }

  fetch(options) {

    var context       = this;
   

    var data  = {
      id: this.props.id,
      
    }
    $.ajax({

      url: "/api/v1/data_stores/for_writeoff/fetch",
      data: data,
      method: 'GET',

      success: function(response) {
        context.setState({
          isLoading: false,
          data: response
          
        });
      },
      error: function(response) {
        alert("Something went wrong when fetching data store");
      }
    });
  }

  componentDidMount() {
    var context = this;

    $.ajax({
      url: "/api/v1/data_stores/for_writeoff/fetch",
      data: {
        id: context.props.id
      },

      method: 'GET',

      success: function(response) {
        console.log(response);
        context.setState({
          isLoading: false,
          data: response,
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

  


renderMembersData(){
    var rows  = [];
    var member_data = this.state.data.data.records;

    for(var i = 0; i < member_data.length; i++) {
      rows.push(
        <tr key={"member_data-item-" + i}>
          <td className="text-left">
            <a href={"/members/" + member_data[i].id+"/display"} target='_blank' >
            {member_data[i].last_name + ", " + member_data[i].first_name + " " + member_data[i].middle_name} </a>
          </td>
          <td className="text-center">
            {member_data[i].member_id}
          </td>
          <td className="text-center">
            {member_data[i].member_status}
          </td>
          <td className="text-center">
            <a href={"/loans/" + member_data[i].loan_id} target='_blank'>
            {member_data[i].loan_product}</a>
          </td>
          <td className="text-center">
            {member_data[i].maturity_date}
          </td>
          <td className="text-center">
            {member_data[i].loan_status}
          </td>
          <td className="text-right">
            {member_data[i].total_balance}
          </td>
          <td className="text-right">
            <a href={"/savings_accounts/" + member_data[i].psa_id} target='_blank'>
            {member_data[i].psa_balance}</a>
          </td>
          <td className="text-right">
            <a href={"/savings_accounts/" + member_data[i].rsa_id} target='_blank'>
            {member_data[i].rsa_balance}</a>
          </td>
          <td className="text-right">
            <a href={"/equity_accounts/" + member_data[i].cbu_id} target='_blank'>
            {member_data[i].cbu_balance}</a>
          </td>
          <td className="text-right">
            <a href={"/equity_accounts/" + member_data[i].equity_id} target='_blank'>
            {member_data[i].equity_balance}</a>
          </td>
          <td className="text-center">
            {member_data[i].center_name}
          </td>


          
        </tr>
      );
    }
    return rows;
}
 renderHeader() {
    var headers = [];
    headers.push(
      <th key="member-header" className="text-center">
        Member
      </th>
    );
    headers.push(
      <th key="identification-number" className="text-center">
        Identification Number
      </th>
    );
     headers.push(
      <th key="member-status" className="text-center">
        Member Status
      </th>
    );
     headers.push(
      <th key="loan-product" className="text-center">
        Loan Product
      </th>
    );
     headers.push(
      <th key="maturity-date" className="text-center">
        Maturity Date
      </th>
    );
    headers.push(
      <th key="loan-status" className="text-center">
        Loan Status
      </th>
    );
    headers.push(
      <th key="total-balance" className="text-center">
        Loan Balance
      </th>
    );
    headers.push(
      <th key="psa-balance" className="text-center">
        Personal Savings Balance
      </th>
    );

    headers.push(
      <th key="rsa-balance" className="text-center">
       RSA Balance
      </th>
    );

    headers.push(
      <th key="cbu-balance" className="text-center">
       CBU Balance
      </th>
    );

    headers.push(
      <th key="share-cap-balance" className="text-center">
       Share Capital Balance
      </th>
    );
    headers.push(
      <th key="center-header" className="text-center">
       Center
      </th>
    );
    return headers;
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
              {this.renderHeader()}
            </tr>
            </thead>
            <tbody>
             {this.renderMembersData()}
            </tbody>
            <tfoot>
            </tfoot>
          </table>
        </div>
      );
    }
  }
}
