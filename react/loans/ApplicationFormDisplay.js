import React from 'react';
import $ from 'jquery';
import moment from 'moment';
import Select from 'react-select';

import SkCubeLoading from '../SkCubeLoading';
import ErrorDisplay from '../ErrorDisplay';
import ApplicationFormFinancialInformation from './ApplicationFormFinancialInformation';
import ApplicationFormCLIPBeneficiary from './ApplicationFormCLIPBeneficiary';

export default class ApplicationFormDisplay extends React.Component {
  constructor(props) {
    super(props);

    this.state  = {
      isLoading: true,
      isSaving: false,
      isActive: false,
      coMakers: [],
      loanProducts: [],
      currentLoanProductId: "",
      projectTypeCategories: [],
      currentProjectTypeId: "",
      data: false,
      errors: false
    };
  }

  componentDidMount() {
    var context = this;

    var data  = {
      id: this.props.id,
      member_id: this.props.memberId
    }

    // Fetch co_makers
    $.ajax({
      url: "/api/v1/members/member_co_makers",
      data: {
        id: context.props.memberId
      },
      method: 'GET',
      success: function(response) {
        context.setState({
          coMakers: response.co_makers
        });
      },
      error: function(response) {
        console.log(response);
      }
    });

    // Fetch loan_products
    $.ajax({
      url: "/api/v1/members/member_loan_products",
      data: {
        id: context.props.memberId
      },
      method: 'GET',
      success: function(response) {
        console.log("Got Loan Products");
        console.log(response);
        console.log(context.state.data);
        // Set currentLoanProductId
        var data  = context.state.data;

        context.setState({
          loanProducts: response.loan_products,
          data: data
        });
      },
      error: function(response) {
        console.log(response);
      }
    });

    $.ajax({
      url: "/api/v1/loans/fetch",
      data: data,
      method: 'GET',
      success: function(response) {
        console.log(response);
        var currentProjectTypeId  = context.state.currentProjectTypeId;

        if(response.project_type_categories.length > 0) {
          if(response.project_type_categories[0].project_types.length > 0) {
            currentProjectTypeId  = response.project_type_categories[0].project_types[0].id
          }
        }

        context.setState({
          isLoading: false,
          data: response.loan,
          projectTypeCategories: response.project_type_categories,
          currentProjectTypeId: currentProjectTypeId
        });
      },
      error: function(response) {
        console.log(response);
        alert("Something went wrong when fetching loan");
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

  updateData(data) {
    this.setState({
      data: data
    });
  }

  handleDatePrepared(event) {
    var data  = this.state.data;

    data.date_prepared  = event.target.value;

    this.updateData(data);
  }

  handleDateReleased(event) {
    var data  = this.state.data;

    data.date_released  = event.target.value;

    this.updateData(data);
  }

  handlePnNumber(event) {
    var data  = this.state.data;

    data.pn_number  = event.target.value;

    this.updateData(data);
  }

  handleClipNumber(event) {
    var data  = this.state.data;

    data.data.clip_number = event.target.value;

    //data.data.voucher.particular  = data.data.voucher.particular.replace(/clip#/g, "clip# " + data.data.clip_number);

    this.updateData(data);
  }

  handlePrincipal(event) {
    var data  = this.state.data;

    data.principal  = event.target.value;

    this.updateData(data);
  }

  handleCoMakerTwo(event) {
    var data  = this.state.data;

    data.data.co_maker_two  = event.target.value.toUpperCase();

    this.updateData(data);
  }

  handleCoMakerOne(o) {
    var data  = this.state.data;

    for(var i = 0; i < this.state.coMakers.length; i++) {
      if(this.state.coMakers[i].id == o.value) {
        data.data.co_maker_one  = this.state.coMakers[i];
      }
    }

    this.updateData(data);
  }

  handleNumInstallments(event) {
    var data  = this.state.data;

    data.num_installments = event.target.value;

    this.updateData(data);
  }

  handleTerm(event) {
    var data  = this.state.data;

    data.term = event.target.value;

    this.updateData(data);
  }

  handleVoucherParticular(event) {
    var data  = this.state.data;

    data.data.voucher.particular  = event.target.value;

    this.updateData(data);
  }

  handleSave() {
    var context = this;
    var state   = context.state;

    this.setState({
      isSaving: true
    });

    $.ajax({
      url: "/api/v1/loans/save",
      method: "POST",
      data: {
        data: JSON.stringify(state.data),
        authenticity_token: context.props.authenticityToken
      },
      success: function(response) {
        window.location.href="/loans/" + response.id;
      },
      error: function(response) {
        try {
          context.setState({
            errors: JSON.parse(response.responseText),
            isSaving: false
          });
        } catch(err) {
          alert("Something went wrong");
          context.setState({
            errors: false,
            isSaving: false
          });
        }
      }
    });
  }

  handleCancel() {
    window.location.href="/members/" + this.props.memberId + "/display";
  }

  handleLoanProduct(event) {
    var data  = this.state.data;

    data.loan_product_id  = event.target.value;

    this.updateData(data);
  }

  renderLoanProducts() {
    var data                = this.state.data;
    var loanProducts        = this.state.loanProducts;
    var loanProductsDisplay = [];

    loanProductsDisplay.push(
      <option value="" key={"empty-loan-product"}>
        -- SELECT --
      </option>
    );

    for(var i = 0; i < loanProducts.length; i++) {
      if(loanProducts[i].id == data.loan_product_id) {
        console.log("Got loan product id: " + data.loan_product_id);
      } else {
        console.log("LP ID: " + data.loan_product_id + " i: " + loanProducts[i].id);
      }

      loanProductsDisplay.push(
        <option value={loanProducts[i].id} key={"loan-product-" + loanProducts[i].id}>
          {loanProducts[i].name}
        </option>
      );
    }

    return loanProductsDisplay;
  }

  renderNumInstallmentOptions() {
    var term  = this.state.data.term;
    var termItems = [];

    if(term == "weekly") {
      termItems.push(
        <option value={15} key={"weekly-" + 15}>
          15
        </option>
      );

      termItems.push(
        <option value={25} key={"weekly-" + 25}>
          25
        </option>
      );

      termItems.push(
        <option value={35} key={"weekly-" + 35}>
          35
        </option>
      );

      termItems.push(
        <option value={50} key={"weekly-" + 50}>
          50
        </option>
      );
    } else if(term == "monthly") {
      termItems.push(
        <option value={3} key={"monthly-" + 3}>
          3
        </option>
      );

      termItems.push(
        <option value={6} key={"monthly-" + 6}>
          6
        </option>
      );

      termItems.push(
        <option value={9} key={"monthly-" + 9}>
          9
        </option>
      );

      termItems.push(
        <option value={12} key={"monthly-" + 12}>
          12
        </option>
      );
    } else if(term == "semi-monthly") {
      termItems.push(
        <option value={6} key={"semi-monthly-" + 6}>
          6
        </option>
      );

      termItems.push(
        <option value={12} key={"semi-monthly-" + 12}>
          12
        </option>
      );

      termItems.push(
        <option value={18} key={"semi-monthly-" + 18}>
          18
        </option>
      );

      termItems.push(
        <option value={24} key={"semi-monthly-" + 24}>
          24
        </option>
      );
    }

    return termItems;
  }

  render() {
    if(this.state.isLoading) {
      return  (
        <SkCubeLoading/>
      );
    } else {
      var data  = this.state.data;
      var coMakerOne  = { 
        value: data.data.co_maker_one.id,
        label: data.data.co_maker_one.last_name + ", " + data.data.co_maker_one.first_name
      };

      return  (
        <div>
          {this.renderErrorDisplay()}
          <h5>
            Co-maker Information
          </h5>
          <div className="card">
            <div className="card-body">
              <div className="row">
                <div className="col">
                  <div className="form-group">
                    <label>
                      Pangalan ng Co-maker (Kamag-anak)
                    </label>
                    <input
                      className="form-control"
                      value={data.data.co_maker_two}
                      onChange={this.handleCoMakerTwo.bind(this)}
                      disabled={this.state.isSaving || this.state.isActive}
                    />
                  </div>
                </div>
                <div className="col">
                  <div className="form-group">
                    <label>
                      Pangalan ng Co-maker (Kasama sa sentro)
                    </label>
                    <Select
                      value={coMakerOne}
                      options={this.state.coMakers}
                      onChange={this.handleCoMakerOne.bind(this)}
                      disabled={this.state.isSaving || this.state.isActive}
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="row">
            <div className="col">
              <div className="form-group">
                <label>
                  * PN Number
                </label>
                <input
                  className="form-control"
                  value={data.pn_number}
                  onChange={this.handlePnNumber.bind(this)}
                  disabled={this.state.isSaving || this.state.isActive}
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>
                  CLIP Number
                </label>
                <input
                  className="form-control"
                  value={data.data.clip_number}
                  onChange={this.handleClipNumber.bind(this)}
                  disabled={this.state.isSaving || this.state.isActive}
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>
                  * Date Prepared
                </label>
                <input
                  className="form-control"
                  type="date"
                  value={data.date_prepared}
                  onChange={this.handleDatePrepared.bind(this)}
                  disabled={this.state.isSaving || this.state.isActive}
                />
              </div>
            </div>
            <div className="col">
              <div className="form-group">
                <label>
                  Date Released
                </label>
                <input
                  className="form-control"
                  type="date"
                  value={data.date_released}
                  onChange={this.handleDateReleased.bind(this)}
                  disabled={this.state.isSaving || this.state.isActive}
                />
              </div>
            </div>
          </div>
          <h5>
            Loan Information
          </h5>
          <div className="card">
            <div className="card-body">
              <div className="row">
                <div className="col">
                  <div className="form-group">
                    <label>
                      * Halaga ng Hinihiram
                    </label>
                    <input
                      className="form-control"
                      type="number"
                      value={data.principal}
                      onChange={this.handlePrincipal.bind(this)}
                      disabled={this.state.isSaving || this.state.isActive}
                    />
                  </div>
                </div>
                <div className="col">
                  <div className="form-group">
                    <label>
                      Loan Product
                    </label>
                    <select
                      className="form-control"
                      value={data.loan_product_id || "-1"}
                      onChange={this.handleLoanProduct.bind(this)}
                      disabled={this.state.isSaving || this.state.isActive}
                    >
                      {this.renderLoanProducts()}
                    </select>
                  </div>
                </div>
                <div className="col">
                  <div className="form-group">
                    <label>
                      Term
                    </label>
                    <select
                      className="form-control"
                      value={data.num_installments}
                      onChange={this.handleNumInstallments.bind(this)}
                    >
                      {this.renderNumInstallmentOptions()}
                    </select>
                  </div>
                </div>
                <div className="col">
                  <div className="form-group">
                    <label>
                      Mode of Payment
                    </label>
                    <select
                      className="form-control"
                      value={data.term}
                      onChange={this.handleTerm.bind(this)}
                    >
                      <option value="weekly">Weekly</option>
                      <option value="monthly">Monthly</option>
                      <option value="semi-monthly">Semi-monthly</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <hr/>
          <h5>
            Financial Information
          </h5>
          <div className="card">
            <div className="card-body">
              <ApplicationFormFinancialInformation
                data={this.state.data}
                updateData={this.updateData.bind(this)}
                disabled={this.state.isSaving || this.state.isActive}
                banks={this.props.banks}
              />
            </div>
          </div>
          <hr/>
          <h5>
            CLIP Beneficiary
          </h5>
          <div className="card">
            <div className="card-body">
              <ApplicationFormCLIPBeneficiary
                data={this.state.data}
                updateData={this.updateData.bind(this)}
                disabled={this.state.isSaving || this.state.isActive}
              />
            </div>
          </div>
          <h5>
            Project Type
          </h5>
          <div className="card">
            <div className="card-body">
            </div>
          </div>
          <hr/>
          {this.renderErrorDisplay()}
          <div className="row">
            <div className="col">
              <div className="btn-group">
                <button
                  className="btn btn-primary"
                  onClick={this.handleSave.bind(this)}
                  disabled={this.state.isSaving || this.state.isActive}
                >
                  <span className="fa fa-check"/>
                  Save
                </button>
                <button
                  className="btn btn-danger"
                  onClick={this.handleCancel.bind(this)}
                  disabled={this.state.isSaving || this.state.isActive}
                >
                  <span className="fa fa-times"/>
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      );
    }
  }
}
