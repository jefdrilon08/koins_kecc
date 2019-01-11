import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';
import Toggle from 'react-toggle';
import "react-toggle/style.css";

import SkCubeLoading from '../../SkCubeLoading';
import ErrorDisplay from '../../ErrorDisplay';

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
      url: "/api/v1/data_stores/personal_funds/fetch",
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

  renderDisplay() {
    return  (
      <div>
        Personal Funds
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
          {this.renderDisplay()}
        </div>
      );
    }
  }
}
