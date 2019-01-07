import React from 'react';
import $ from 'jquery';
import moment from 'moment';

import SkCubeLoading from '../SkCubeLoading';
import {numberWithCommas} from '../utils/helpers';

export default class AccountingEntrySubsidiaryBalancingComponent extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: false,
      data: false,
      branches: props.branches,
      currentBranchId: "",
      asOf: props.asOf
    };
  }

  componentDidMount() {
    if(this.state.branches.length > 0) {
      this.setState({
        currentBranchId: this.state.branches[0].id
      });
    }
  }

  handleBranchChanged(event) {
    this.setState({
      currentBranchId: event.target.value
    });
  }

  handleAsOfChanged(event) {
    this.setState({
      asOf: event.target.value
    });
  }

  handleGenerateClicked() {
    var params  = {
      branch_id: this.state.currentBranchId,
      as_of: this.state.asOf
    }

    this.setState({
      isLoading: true
    });
  }

  renderResult() {
    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(this.state.data) {
      return  (
        <div>
          RESULT
        </div>
      );
    } else {
      return  (
        <p>
          No data found.
        </p>
      );
    }
  }

  renderBranchOptions() {
    var options   = [];
    var branches  = this.state.branches;

    for(var i = 0; i < branches.length; i++) {
      options.push(
        <option value={branches[i].id}>
          {branches[i].name}
        </option>
      );
    }

    return options;
  }

  renderFilter() {
    return  (
      <div className="row">
        <div className="col-md-8">
          <div className="form-group">
            <label>
              <strong>
                Branch:
              </strong>
            </label>
            <select
              value={this.state.currentBranchId}
              className="form-control"
              onChange={this.handleBranchChanged.bind(this)}
              disabled={this.state.isLoading}
            >
              {this.renderBranchOptions()}
            </select>
          </div>
        </div>
        <div className="col-md-2">
          <div className="form-group">
            <label>
              <strong>
                As Of:
              </strong>
            </label>
            <input
              type="date"
              className="form-control"
              onChange={this.handleAsOfChanged.bind(this)}
              value={this.state.asOf}
              disabled={this.state.isLoading}
            />
          </div>
        </div>
        <div className="col-md-2">
          <div className="form-group">
            <label>
              <strong>
                Actions:
              </strong>
            </label>
            <button
              className="btn btn-info btn-block"
              onClick={this.handleGenerateClicked.bind(this)}
              disabled={this.state.isLoading}
            >
              <span className="fa fa-sync"/>
              Generate
            </button>
          </div>
        </div>
      </div>
    );
  }

  render() {
    return  (
      <div>
        {this.renderFilter()}
        <hr/>
        {this.renderResult()}
      </div>
    );
  }
}
