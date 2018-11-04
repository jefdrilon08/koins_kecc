import React from 'react';
import $ from 'jquery';

import ReactTable from 'react-table';
import 'react-table/react-table.css';

import SkCubeLoading from '../SkCubeLoading';
import ErrorDisplay from '../ErrorDisplay';

import FormApplicationHeader from './FormApplicationHeader';
import FormPersonalInfo from './FormPersonalInfo';
import FormNumChildren from './FormNumChildren';
import FormContactNumbers from './FormContactNumbers';
import FormGovernmentIdentificationNumbers from './FormGovernmentIdentificationNumbers';
import FormSpouse from './FormSpouse';
import FormExperience from './FormExperience';

export default class FormDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      formDisabled: false,
      data: false,
      memberId: props.id,
      authenticityToken: props.authenticityToken,
      branches: [],
      centers: [],
      currentBranch: {
        value: "",
        label: ""
      },
      currentCenter: {
        value: "",
        label: ""
      },
      errors: false
    };
  }

  componentDidMount() {
    this.fetch();
  }

  updateCurrentCenter(o) {
    this.setState({
      currentCenter: o
    });
  }

  updateCurrentBranch(o) {
    var centers = [];
    for(var i = 0; i < this.state.branches.length; i++) {
      if(this.state.branches[i].id == o.value) {
        for(var j = 0; j < this.state.branches[i].centers.length; j++) {
          centers = this.state.branches[i].centers;
        }
      }
    }

    this.setState({
      currentBranch: o,
      centers: centers,
      currentCenter: {
        value: centers[0].id,
        label: centers[0].name
      }
    });

  }

  fetchBranches() {
    var context = this;

    $.ajax({
      url: "/api/v1/branches",
      method: "GET",
      data: {
        
      },
      dataType: 'json',
      success: function(response) {
        var tempCurrentBranch = {
          value: response.branches[0].id,
          label: response.branches[0].name
        };

        var tempCurrentCenter = {
          value: response.branches[0].centers[0].id,
          label: response.branches[0].centers[0].name
        }

        context.setState({
          branches: response.branches,
          centers: response.branches[0].centers,
          currentBranch: tempCurrentBranch,
          currentCenter: tempCurrentCenter
        });
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching branches");

        context.setState({
          branches: []
        });
      }
    });
  }

  save() {
    var context = this;
    var state   = context.state;

    $.ajax({
      url: "/api/v1/members/save",
      method: "POST",
      data: {
        id: state.memberId,
        member_data: state.data,
        authenticity_token: state.authenticityToken
      },
      success: function(response) {
        window.location.href="/members/" + response.id
      },
      error: function(response) {
        try {
          context.setState({
            errors: JSON.parse(response.responseText),
            formDisabled: false
          });
        } catch(err) {
          alert("Something went wrong");
          context.setState({
            errors: false,
            formDisabled: false
          });
        }
      }
    });
  }

  fetch() {
    var context = this;

    $.ajax({
      url: "/api/v1/members/fetch",
      method: "GET",
      data: {
        id: context.state.memberId
      },
      dataType: 'json',
      success: function(response) {
        console.log(response);
        context.setState({
          isLoading: false,
          data: response
        });
        context.fetchBranches();
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching members data");

        context.setState({
          isLoading: true,
          data: false
        });
      }
    });
  }

  handleSave() {
    var context = this;
    var state   = context.state;

    context.setState({
      formDisabled: true,
      errors: false
    });

    context.save();
  }

  handleCancel() {
    var context = this;
    var state   = context.state;

    if(state.id) {
      window.location.href="/members/" + state.id;
    } else {
      window.location.href="/members";
    }
  }

  updateData(data) {
    this.setState({
      data: data
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

  render() {
    var context = this;
    var state   = context.state;

    if(state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else if(state.data != false) {
      return (
        <div>
          <h2>Member Form</h2>
          <hr/>
          {this.renderErrorDisplay()}
          <div className="row">
            <div className="col">
              <FormApplicationHeader
                data={state.data}
                currentBranch={state.currentBranch}
                currentCenter={state.currentCenter}
                branches={state.branches}
                centers={state.centers}
                updateData={this.updateData.bind(this)}
                formDisabled={state.formDisabled}
                updateCurrentBranch={this.updateCurrentBranch.bind(this)}
                updateCurrentCenter={this.updateCurrentCenter.bind(this)}
              />

              <div className="card">
                <div className="card-header">
                  Personal na Impormasyon
                </div>
                <div className="card-body">
                  <FormPersonalInfo
                    data={state.data}
                    updateData={this.updateData.bind(this)}
                    formDisabled={state.formDisabled}
                  />

                  <FormNumChildren
                    data={state.data}
                    updateData={this.updateData.bind(this)}
                    formDisabled={state.formDisabled}
                  />

                  <FormContactNumbers
                    data={state.data}
                    updateData={this.updateData.bind(this)}
                    formDisabled={state.formDisabled}
                  />

                  <FormGovernmentIdentificationNumbers
                    data={state.data}
                    updateData={this.updateData.bind(this)}
                    formDisabled={state.formDisabled}
                  />
                </div>
              </div>

              <div className="card">
                <div className="card-header">
                  Personal na Impormasyon ng Asawa o Kinakasama (Common-law Spouse)
                </div>
                <div className="card-body">
                  <FormSpouse
                    data={state.data}
                    updateData={this.updateData.bind(this)}
                    formDisabled={state.formDisabled}
                  />
                </div>
              </div>

              <div className="card">
                <div className="card-header">
                  Background sa Pahiraman
                </div>
                <div className="card-body">
                  <FormExperience
                    data={state.data}
                    updateData={this.updateData.bind(this)}
                    formDisabled={state.formDisabled}
                  />
                </div>
              </div>
            </div>
          </div>
          <div className="row">
            <div className="col">
              {this.renderErrorDisplay()}
              <div className="btn-group">
                <button 
                  className="btn btn-primary" 
                  onClick={this.handleSave.bind(this)}
                  disabled={this.state.formDisabled}
                >
                  <span className="fa fa-check"/>
                  Save Record
                </button>
                <button 
                  className="btn btn-danger" 
                  onClick={this.handleCancel.bind(this)}
                  disabled={this.state.formDisabled}
                >
                  <span className="fa fa-times"/>
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      );
    } else {
      <div>
        No data
      </div>
    }
  }
}
