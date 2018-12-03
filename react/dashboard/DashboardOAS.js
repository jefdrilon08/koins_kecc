import React from 'react';
import $ from 'jquery';
import Select from 'react-select';

import SkCubeLoading from '../SkCubeLoading';

export default class DashboardOAS extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      currentBranch: {
        id: "",
        name: "",
        centers: []
      },
      branches: [],
      data: {
      },
      isLoading: false
    }
  }

  componentDidMount() {
    var context = this;
    $.ajax({
      url: '/api/v1/branches',
      success: function(response) {
        var currentBranch = {
          id: "",
          name: "",
          centers: []
        };

        if(response.branches.length > 0) {
          currentBranch = response.branches[0]; 
        }

        context.setState({
          branches: response.branches,
          currentBranch: currentBranch
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching branches!");
      }
    });
  }

  handleBranchChanged(o) {
    var currentBranch = this.state.currentBranch;

    for(var i = 0; i < this.state.branches.length; i++) {
      if(this.state.branches[i].id == o.value) {
        currentBranch = this.state.branches[i];
      }
    }

    this.setState({
      currentBranch: currentBranch
    });
  }

  handleSyncClicked() {
    var context       = this;
    var currentBranch = this.state.currentBranch;

    context.setState({
      isLoading: true
    });
  }

  renderControls() {
    var state = this.state;

    var branch  = {
      value: state.currentBranch.id,
      label: state.currentBranch.name
    };

    var branchOptions = []

    for(var i = 0; i < this.state.branches.length; i++) {
      branchOptions.push({
        value: this.state.branches[i].id,
        label: this.state.branches[i].name
      });
    }

    return  (
      <div className="row">
        <div className="col-md-9">
          <div className="form-group">
            <label>
              Branch
            </label>
            <Select
              options={branchOptions}
              onChange={this.handleBranchChanged.bind(this)}
              value={branch}
            />
          </div>
        </div>
        <div className="col-md-3">
          <div className="form-group">
            <label>
              Actions
            </label>
            <br/>
            <div className="btn-group">
              <button
                className="btn btn-primary"
                onClick={this.handleSyncClicked.bind(this)}
                disabled={this.state.isLoading}
              >
                <span className="fa fa-sync"/>
                Sync
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  renderData() {
    return  (
      <div></div>
    );
  }

  render() {
    return  (
      <div>
        {this.renderControls()}
        <hr/>
        {this.renderData()} 
      </div>
    );
  }
}
