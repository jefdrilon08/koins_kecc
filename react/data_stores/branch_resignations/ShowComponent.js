import React from 'react';
import $ from 'jquery';

import SkCubeLoading from '../../SkCubeLoading';
import ErrorDisplay from '../../ErrorDisplay';

import ResignationDisplay from './ResignationDisplay';

export default class ShowComponent extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      data: false,
      meta: false,
      errors: false
    };
  }

  componentDidMount() {
    var context = this;

    var data  = {
      id: this.props.id
    }

    $.ajax({
      url: "/api/v1/data_stores/branch_resignations/fetch",
      data: data,
      method: 'GET',
      success: function(response) {
        console.log(response);
        context.setState({
          isLoading: false,
          data: response.data,
          meta: response.meta
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

  renderRecords() {
    var data    = this.state.data;
    var records = [];

    for(var i = 0; i < data.records.length; i++) {
      records.push(
        <ResignationDisplay 
          index={i}
          key={"category-" + i}
          data={data.records[i]}
        />
      );
    }

    return records;
  };

  render() {
    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      return  (
        <div>
          <h2>
            {this.state.meta.branch_name} Resignations 
          </h2>
          <small className="text-muted">
            {this.state.meta.start_date} to {this.state.meta.end_date}
          </small>
          {this.renderRecords()}
        </div>
      );
    }
  }
}
