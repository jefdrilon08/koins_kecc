import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';
import Toggle from 'react-toggle';
import "react-toggle/style.css";

import SkCubeLoading from '../../SkCubeLoading';
import ErrorDisplay from '../../ErrorDisplay';
import {numberWithCommas} from '../../utils/helpers';
import Filter from './Filter';
import MasterListView from './MasterListView';
import ManualAgingView from './ManualAgingView';
import AgingOfReceivablesView from './AgingOfReceivablesView';

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
      currentLoanProductId: "",
      currentView: "RR"
    };
  }

  fetch(options) {
    var context       = this;
    var centerId      = options.centerId;
    var loanProductId = options.loanProductId;
    var officerId     = options.officerId;

    var data  = {
      id: this.props.id,
      center_id: centerId,
      loan_product_id: loanProductId,
      officer_id: officerId
    }

    console.log("fetch (data):");
    console.log(data);

    this.setState({
      currentCenterId: centerId,
      currentLoanProductId: loanProductId,
      currentOfficerId: officerId
    });

    $.ajax({
      url: "/api/v1/data_stores/manual_aging/fetch",
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
      url: "/api/v1/data_stores/manual_aging/fetch",
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

  handleCenterChanged(event) {
    this.fetch({
      centerId: event.target.value,
      officerId: this.state.currentOfficerId,
      loanProductId: this.state.currentLoanProductId
    });
  }

  handleOfficerChanged(event) {
    this.fetch({
      centerId: this.state.currentCenterId,
      officerId: event.target.value,
      loanProductId: this.state.currentLoanProductId
    });
  }

  handleLoanProductChanged(event) {
    this.fetch({
      centerId: this.state.currentCenterId,
      officerId: this.state.currentOfficerId,
      loanProductId: event.target.value
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

  handleViewToggled(viewName) {
    this.setState({
      currentView: viewName
    });
  }

  render() {
    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(this.state.currentView == "RR") {
      return  (
        <div>
          <Filter
            currentView={this.state.currentView} 
            handleViewToggled={this.handleViewToggled.bind(this)}
            centers={this.state.data.data.centers}
            officers={this.state.data.data.officers}
            loanProducts={this.state.data.data.loan_products}
            currentCenterId={this.state.currentCenterId}
            currentLoanProductId={this.state.currentLoanProductId}
            handleCenterChanged={this.handleCenterChanged.bind(this)}
            handleLoanProductChanged={this.handleLoanProductChanged.bind(this)}
            handleOfficerChanged={this.handleOfficerChanged.bind(this)}
          />
          <ManualAgingView
            data={this.state.data}
          />
        </div>
      );
    } else if(this.state.currentView == "AOR") {
      return  (
        <div>
          <Filter
            currentView={this.state.currentView} 
            handleViewToggled={this.handleViewToggled.bind(this)}
            centers={this.state.data.data.centers}
            officers={this.state.data.data.officers}
            loanProducts={this.state.data.data.loan_products}
            currentCenterId={this.state.currentCenterId}
            currentLoanProductId={this.state.currentLoanProductId}
            handleCenterChanged={this.handleCenterChanged.bind(this)}
            handleLoanProductChanged={this.handleLoanProductChanged.bind(this)}
            handleOfficerChanged={this.handleOfficerChanged.bind(this)}
          />
          <AgingOfReceivablesView
            data={this.state.data}
          />
        </div>
      );
    } else if(this.state.currentView == "ML") {
      return  (
        <div>
          <Filter
            currentView={this.state.currentView} 
            handleViewToggled={this.handleViewToggled.bind(this)}
            centers={this.state.data.data.centers}
            officers={this.state.data.data.officers}
            loanProducts={this.state.data.data.loan_products}
            currentCenterId={this.state.currentCenterId}
            currentLoanProductId={this.state.currentLoanProductId}
            handleCenterChanged={this.handleCenterChanged.bind(this)}
            handleLoanProductChanged={this.handleLoanProductChanged.bind(this)}
            handleOfficerChanged={this.handleOfficerChanged.bind(this)}
          />
          <MasterListView
            data={this.state.data}
          />
        </div>
      );
    } else {
      return  (
        <div>
          <p>
            Invalid view name: {this.state.currentView}
          </p>
        </div>
      );
    }
  }
}
