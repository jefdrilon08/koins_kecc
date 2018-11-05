import React from "react";

export default class FormExperience extends React.Component {
  constructor(props) {
    super(props);
  }

  handleReasonChanged(event) {
    var data                      = this.props.data;
    data.data.reason_for_joining  = event.target.value;

    this.props.updateData(data);
  }

  render() {
    return (
      <div>
        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>
                Reason for Joining
              </label>
              <input
                value={this.props.data.data.reason_for_joining}
                className="form-control"
                onChange={this.handleReasonChanged.bind(this)}
                disabled={this.props.formDisabled}
              />
            </div>
          </div>
        </div>
      </div>
    );
  }
}
