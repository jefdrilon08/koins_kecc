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

  handleHousingTypeChanged(event) {
    var data                = this.props.data;

    if(event.target.value) {
      data.data.housing.type  = event.target.value;
      this.props.updateData(data);
    }
  }

  handleHousingNumYearsChanged(event) {
    var data                    = this.props.data;
    data.data.housing.num_years = event.target.value;
    this.props.updateData(data);
  }

  handleHousingNumMonthsChanged(event) {
    var data                      = this.props.data;
    data.data.housing.num_months  = event.target.value;
    this.props.updateData(data);
  }

  handleHousingProofChanged(event) {
    var data                    = this.props.data;
    data.data.housing.proof     = event.target.value;
    this.props.updateData(data);
  }

  render() {
    console.log(this.props.data);
    var housingType       = this.props.data.data.housing.type;
    var housingNumYears   = this.props.data.data.housing.num_years;
    var housingNumMonths  = this.props.data.data.housing.num_months;
    var housingProof      = this.props.data.data.housing.proof;

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
                <label>Apelyido</label>
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
          <div className="row">
            <div className="col-md-4">
              <div className="form-group">
                <label>
                  Uri ng Paninirahan
                </label>
                <br/>
                <input
                  type="radio"
                  value={"Pag-aari ang lupa"}
                  checked={housingType == "Pag-aari ang lupa"}
                  onChange={this.handleHousingTypeChanged.bind(this)}
                />
                Pag-aari ang lupa
                <br/>
                <input
                  type="radio"
                  value={"Umuupa"}
                  checked={housingType == "Umuupa"}
                  onChange={this.handleHousingTypeChanged.bind(this)}
                />
                Umuupa
                <br/>
                <input
                  type="radio"
                  value={"Nakikituloy"}
                  checked={housingType == "Nakikituloy"}
                  onChange={this.handleHousingTypeChanged.bind(this)}
                />
                Nakikituloy
                <br/>
                <input
                  type="radio"
                  value={"Namana"}
                  checked={housingType == "Namana"}
                  onChange={this.handleHousingTypeChanged.bind(this)}
                />
                Namana
                <br/>
                <input
                  type="radio"
                  value={"Nagbabayad ng Rights"}
                  checked={housingType == "Nagbabayad ng Rights"}
                  onChange={this.handleHousingTypeChanged.bind(this)}
                />
                Nagbabayad ng Rights
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group">
                <label>
                  Tagal sa Tirahan (taon)
                </label>
                <input
                  type="number"
                  value={housingNumYears}
                  onChange={this.handleHousingNumYearsChanged.bind(this)}
                  className="form-control"
                />
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group">
                <label>
                  Tagal sa Tirahan (buwan)
                </label>
                <input
                  type="number"
                  value={housingNumMonths}
                  onChange={this.handleHousingNumMonthsChanged.bind(this)}
                  className="form-control"
                />
              </div>
            </div>
          </div>
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>
                  Ipinakitang Katibayan
                </label>
                <input
                  value={housingProof}
                  onChange={this.handleHousingProofChanged.bind(this)}
                  className="form-control"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
