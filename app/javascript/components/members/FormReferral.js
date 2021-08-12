import React from "react";

export default class FormReferral extends React.Component {
  constructor(props) {
    super(props);
  }

  handleReferChanged(event) {
    var data               = this.props.data;
    data.data.referred_by  = event.target.value ? event.target.value.toUpperCase() : "";

    this.props.updateData(data);
  }


  render() {
    var data  = this.props.data;

    return (
      <div>
        <div className="row">
          <div className="col">
            <div className="form-group">
              <label>
                Pangalan ng nag refer
              </label>
              <input
                value={this.props.data.data.referred_by}
                className="form-control"
                onChange={this.handleReferChanged.bind(this)}
                disabled={this.props.formDisabled}
              />
            </div>
          </div>
        </div>
      </div>
    );
  }
}
