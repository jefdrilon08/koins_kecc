import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';

import SkCubeLoading from '../../SkCubeLoading';
import ErrorDisplay from '../../ErrorDisplay';

import LoanProduct from './LoanProduct';

export default class ShowDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false,
      errors: false
    };
  }

  componentDidMount() {
    var context = this;

    var data  = {
      id: this.props.id
    }

    $.ajax({
      url: "/api/v1/data_stores/branch_repayment_reports/fetch",
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

  renderErrorDisplay() {
    if(this.state.errors) {
      return  (
        <ErrorDisplay
          errors={this.state.errors}
        />
      );
    }
  }

  buildOfficerOptions() {
    var officerOptions  = [];

    return officerOptions;
  }

  buildCenterOptions() {
    var centerOptions = [];

    return centerOptions;
  }

  buildLoanProductOptions() {
    var loanProductOptions  = [];

    return loanProductOptions;
  }

  renderLoanProductLevel() {
    var loanProducts  = [];
    var data          = this.state.data.data;

    for(var i = 0; i < data.loan_products.length; i++) {
      loanProducts.push(
        <LoanProduct
          key={"lp" + i}
          data={data.loan_products[i]}
        />
      );
    }
    
    return  loanProducts;
  }

  render() {
    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      return  (
        <div>
          {this.renderLoanProductLevel()}
        </div>
      );
    }
  }
}
