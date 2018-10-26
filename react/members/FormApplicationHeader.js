import React from "react";
import Select from 'react-select';

export default class FormApplicationHeader extends React.Component {
  constructor(props) {
    super(props);
  }

  handleBranchChanged(o) {
    var temp  = "";
    var data  = this.props.data;

    if(o) {
      this.props.updateCurrentBranch(o);
    }
  }

  handleCenterChanged(o) {
    if(o) {
      this.props.updateCurrentCenter(o);
    }
  }

  render() {
    var branchOptions = [];
    var centerOptions = [];

    for(var i = 0; i < this.props.branches.length; i++) {
      if(this.props.branches[i].id == this.props.currentBranch.value) {
        for(var j = 0; j < this.props.branches[i].centers.length; j++) {
          centerOptions.push({
            value: this.props.branches[i].centers[j].id,
            label: this.props.branches[i].centers[j].name
          });
        }
      }

      branchOptions.push({
        value: this.props.branches[i].id,
        label: this.props.branches[i].name
      });

      console.log(centerOptions);
    }

    return  (
      <div className="card">
        <div className="card-header">
          Application for Membership
        </div>
        <div className="card-body">
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>Branch</label>
                <Select
                  value={this.props.currentBranch}
                  options={branchOptions}
                  onChange={this.handleBranchChanged.bind(this)}
                  disabled={this.props.formDisabled}
                />
                <br/>
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>Center</label>
                <Select
                  value={this.props.currentCenter}
                  options={centerOptions}
                  onChange={this.handleCenterChanged.bind(this)}
                  disabled={this.props.formDisabled}
                />
                <br/>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
