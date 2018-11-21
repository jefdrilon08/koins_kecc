import React from "react";
import Select from 'react-select';

import {getReligionOptions} from '../utils/helpers';

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

  handleGenderChanged(event) {
    var data  = this.props.data;

    if(event.target.value) {
      data.gender = event.target.value;
      this.props.updateData(data);
    }
  }

  handleCivilStatusChanged(event) {
    var data  = this.props.data;
    
    if(event.target.value) {
      data.civil_status = event.target.value;
      this.props.updateData(data);
    }
  }

  handleHousingTypeChanged(event) {
    var data  = this.props.data;

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
    data.data.housing.proof     = event.target.value.toUpperCase();
    this.props.updateData(data);
  }

  handleDateOfBirthChanged(event) {
    var data            = this.props.data;
    data.date_of_birth  = event.target.value;
    this.props.updateData(data);
  }

  handlePlaceOfBirthChanged(event) {
    var data            = this.props.data;
    data.place_of_birth = event.target.value.toUpperCase();
    this.props.updateData(data);
  }

  handleReligionChanged(o) {
    var data      = this.props.data;
    data.religion = o.value;
    this.props.updateData(data);
  }

  render() {
    console.log(this.props.data);
    var housingType       = this.props.data.data.housing.type;
    var housingNumYears   = this.props.data.data.housing.num_years;
    var housingNumMonths  = this.props.data.data.housing.num_months;
    var housingProof      = this.props.data.data.housing.proof;

    var currentReligion = {
      label: this.props.data.religion,
      value: this.props.data.religion
    };

    return  (
      <div>
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
              Pag-aari ang lupa at bahay (may titulo)
              <br/>
              <input
                type="radio"
                value={"Umuupa"}
                checked={housingType == "Umuupa"}
                onChange={this.handleHousingTypeChanged.bind(this)}
              />
              Umuupa (sharer or renter)
              <br/>
              <input
                type="radio"
                value={"Nakikituloy"}
                checked={housingType == "Nakikituloy"}
                onChange={this.handleHousingTypeChanged.bind(this)}
              />
              Nakikituloy (libre; mga magulang o extended family)
              <br/>
              <input
                type="radio"
                value={"Namana"}
                checked={housingType == "Namana"}
                onChange={this.handleHousingTypeChanged.bind(this)}
              />
              Namana o na-award pero wala pang titulo
              <br/>
              <input
                type="radio"
                value={"Nagbabayad ng Rights"}
                checked={housingType == "Nagbabayad ng Rights"}
                onChange={this.handleHousingTypeChanged.bind(this)}
              />
              Nagbabayad ng Rights sa lupa, pag-aari ng bahay
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
                disabled={this.props.formDisabled}
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
                disabled={this.props.formDisabled}
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
                disabled={this.props.formDisabled}
              />
            </div>
          </div>
        </div>
        <div className="row">
          <div className="col-md-4">
            <div className="form-group">
              <label>
                * Kapanganakan
              </label>
              <input
                value={this.props.data.date_of_birth}
                className="form-control"
                type="date"
                onChange={this.handleDateOfBirthChanged.bind(this)}
                disabled={this.props.formDisabled}
              />
            </div>
          </div>
          <div className="col-md-4">
            <div className="form-group">
              <label>
                Lugar ng Kapanganakan
              </label>
              <input
                value={this.props.data.place_of_birth}
                className="form-control"
                onChange={this.handlePlaceOfBirthChanged.bind(this)}
                disabled={this.props.formDisabled}
              />
            </div>
          </div>
          <div className="col-md-4">
            <div className="form-group">
              <label>
                * Kasarian
              </label>
              <br/>
              <div className="row">
                <div className="col-md-4">
                  <input
                    type="radio"
                    value={"Female"}
                    checked={this.props.data.gender == "Female"}
                    onChange={this.handleGenderChanged.bind(this)}
                  />
                  Babae
                </div>
                <div className="col-md-4">
                  <input
                    type="radio"
                    value={"Male"}
                    checked={this.props.data.gender == "Male"}
                    onChange={this.handleGenderChanged.bind(this)}
                  />
                  Lalake
                </div>
                <div className="col-md-4">
                  <input
                    type="radio"
                    value={"Others"}
                    checked={this.props.data.gender == "Others"}
                    onChange={this.handleGenderChanged.bind(this)}
                  />
                  Iba Pa
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="row">
          <div className="col-md-6">
            <div className="form-group">
              <label>
                * Katayuang Sibil
              </label>
              <div className="row">
                <div className="col">
                  <input
                    type="radio"
                    value="Single"
                    checked={this.props.data.civil_status == "Single"}
                    onChange={this.handleCivilStatusChanged.bind(this)}
                  />
                  Single
                </div>
                <div className="col">
                  <input
                    type="radio"
                    value="May Kinakasama"
                    checked={this.props.data.civil_status == "May Kinakasama"}
                    onChange={this.handleCivilStatusChanged.bind(this)}
                  />
                  May Kinakasama
                </div>
                <div className="col">
                  <input
                    type="radio"
                    value="Kasal"
                    checked={this.props.data.civil_status == "Kasal"}
                    onChange={this.handleCivilStatusChanged.bind(this)}
                  />
                  Kasal
                </div>
                <div className="col">
                  <input
                    type="radio"
                    value="Hiwalay"
                    checked={this.props.data.civil_status == "Hiwalay"}
                    onChange={this.handleCivilStatusChanged.bind(this)}
                  />
                  Hiwalay
                </div>
                <div className="col">
                  <input
                    type="radio"
                    value="Biyudo/a"
                    checked={this.props.data.civil_status == "Biyudo/a"}
                    onChange={this.handleCivilStatusChanged.bind(this)}
                  />
                  Biyudo/a
                </div>
              </div>
            </div>
          </div>
          <div className="col-md-6">
            <div className="form-group">
              <label>
                Religion
              </label>
              <Select
                value={currentReligion}
                options={getReligionOptions()}
                onChange={this.handleReligionChanged.bind(this)}
                disabled={this.props.formDisabled}
              />
            </div>
          </div>
        </div>
      </div>
    );
  }
}
