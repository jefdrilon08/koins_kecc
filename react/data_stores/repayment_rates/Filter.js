import React from 'react';

import Toggle from 'react-toggle';
import "react-toggle/style.css";

export default class Filter extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
    }
  }

  renderLoanProductOptions() {
    var loanProducts = this.props.loanProducts;
    var options = [];

    options.push(
      <option value="" key={"loan-product-select"}>
        -- SELECT --
      </option>
    );

    for(var i = 0; i < loanProducts.length; i++) {
      options.push(
        <option key={"loan-product-" + loanProducts[i].id} value={loanProducts[i].id}>
          {loanProducts[i].name}
        </option>
      );
    }

    return options;
  }

  renderCenterOptions() {
    var centers = this.props.centers;
    var options = [];

    options.push(
      <option value="" key={"center-select"}>
        -- SELECT --
      </option>
    );

    for(var i = 0; i < centers.length; i++) {
      options.push(
        <option value={centers[i].id} key={"center-" + centers[i].id}>
          {centers[i].name}
        </option>
      );
    }

    return options;
  }

  render() {
    return  (
      <div className="row">
        <div className="col-md-3 col-xs-12">
          <div className="form-group">
            <label>
              View Name
            </label>
            <div className="row">
              <div className="col">
                <Toggle
                  checked={this.props.currentView == "RR"}
                  onChange={this.props.handleViewToggled.bind(this, "RR")}
                  className="btn"
                />
                <br/>
                <label>
                  RR
                </label>
              </div>
              <div className="col">
                <Toggle
                  checked={this.props.currentView == "PAR"}
                  onChange={this.props.handleViewToggled.bind(this, "PAR")}
                  className="btn"
                />
                <br/>
                <label>
                  PAR
                </label>
              </div>
              <div className="col">
                <Toggle
                  checked={this.props.currentView == "ML"}
                  onChange={this.props.handleViewToggled.bind(this, "ML")}
                  className="btn"
                />
                <br/>
                <label>
                  ML
                </label>
              </div>
            </div>
          </div>
        </div>
        <div className="col-md-3 col-xs-12">
          <div className="form-group">
            <label>
              Center
            </label>
            <select
              className="form-control"
              value={this.props.currentCenterId}
              onChange={this.props.handleCenterChanged.bind(this)}
            >
              {this.renderCenterOptions()}
            </select>
          </div>
        </div>
        <div className="col-md-3 col-xs-12">
          <div className="form-group">
            <label>
              Loan Products
            </label>
            <select
              className="form-control"
              value={this.props.currentLoanProductId}
              onChange={this.props.handleLoanProductChanged.bind(this)}
            >
              {this.renderLoanProductOptions()}
            </select>
          </div>
        </div>
        <div className="col-md-3 col-xs-12">
          <div className="form-group">
            <label>
              Actions
            </label>
            <button
              className="btn btn-primary btn-block"
              onClick={this.props.handleFilterClicked.bind(this)}
            >
              <span className="fa fa-sync" />
              Filter
            </button>
          </div>
        </div>
      </div>
    );
  }
}
