import React from "react";
import Select from 'react-select';

export default class FormPersonalInfo extends React.Component {
  constructor(props) {
    super(props);
  }

  handleFirstNameChanged(event) {
    var data        = this.props.data;
    data.first_name = event.target.value ? event.target.value.toUpperCase() : "";

    this.props.updateData(data);
  }

  handleMiddleNameChanged(event) {
    var data          = this.props.data;
    data.middle_name  = event.target.value ? event.target.value.toUpperCase() : "";

    this.props.updateData(data);
  }

  handleLastNameChanged(event) {
    var data        = this.props.data;
    data.last_name  = event.target.value ? event.target.value.toUpperCase() : "";

    this.props.updateData(data);
  }

  handleAddressStreetChanged(event) {
    var data                  = this.props.data;
    data.data.address.street  = event.target.value ? event.target.value.toUpperCase() : "";

    this.props.updateData(data);
  }

  handleAddressDistrictChanged(event) {
    var data                    = this.props.data;
    data.data.address.district  = event.target.value ? event.target.value.toUpperCase() : "";

    this.props.updateData(data);
  }

  handleAddressCityChanged(event) {
    var data                = this.props.data;
    data.data.address.city  = event.target.value ? event.target.value.toUpperCase() : "";

    this.props.updateData(data);
  }

  render() {
    return  (
      <div className="card">
        <div className="card-header">
          Personal na Impormasyon
        </div>
        <div className="card-body">
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>Pangalan</label>
                <input
                  value={this.props.data.first_name}
                  className="form-control"
                  onChange={this.handleFirstNameChanged.bind(this)}
                  disabled={this.props.formDisabled}
                />
              </div>
              <div className="form-group">
                <label>Gitnang Pangalan</label>
                <input
                  value={this.props.data.middle_name}
                  className="form-control"
                  onChange={this.handleMiddleNameChanged.bind(this)}
                  disabled={this.props.formDisabled}
                />
              </div>
              <div className="form-group">
                <label>Apenlyido</label>
                <input
                  value={this.props.data.last_name}
                  className="form-control"
                  onChange={this.handleLastNameChanged.bind(this)}
                  disabled={this.props.formDisabled}
                />
              </div>
            </div>
          </div>
          <h5>
            Tirahan / Address
          </h5>
          <div className="row">
            <div className="col-md-4">
              <div className="form-group">
                <label>* Kalye / Street</label>
                <input
                  value={this.props.data.data.address.street}
                  className="form-control"
                  onChange={this.handleAddressStreetChanged.bind(this)}
                  disabled={this.props.formDisabled}
                />
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group">
                <label>* Barangay</label>
                <input
                  value={this.props.data.data.address.district}
                  className="form-control"
                  onChange={this.handleAddressDistrictChanged.bind(this)}
                  disabled={this.props.formDisabled}
                />
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group">
                <label>* Syudad / City</label>
                <input
                  value={this.props.data.data.address.city}
                  className="form-control"
                  onChange={this.handleAddressCityChanged.bind(this)}
                  disabled={this.props.formDisabled}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
