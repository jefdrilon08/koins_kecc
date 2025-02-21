import React, { useState, useEffect } from 'react';
import "react-toggle/style.css";
import ToggleSwitch from '../../utils/ToggleSwitch';
import $ from 'jquery';


export default Filter = (props) => {
  let {
    loanProducts,
    centers,
    officers,
    status,
    gender,
    currentView,
    currentCenterId,
    currentOfficerId,
    currentLoanProductId,
    currentStatus,
    currentGender,
    handleViewToggled,
    handleCenterChanged,
    handleOfficerChanged,
    handleLoanProductChanged,
    handleStatusChanged,
    handleGenderChanged,
    handleLoanProductTaggingChanged,
  } = props;

  const [loanProductTagging, setLoanProductTagging] = useState([]);
  const [currentLoanProductTaggingId, setCurrentLoanProductTaggingId] = useState("");

  useEffect(() => {
    if (currentLoanProductId) {
      $.ajax({
        url: "/api/loan_product_taggings",
        data: {
          loan_product_id: currentLoanProductId,
        },
        method: "GET",
        success: function (response) {
          setLoanProductTagging(response.loan_product_tagging);
          setCurrentLoanProductTaggingId(response.loan_product_tagging[0]?.id || "");
        },
        error: function (response) {
          console.log(response);
        },
      });
    }
  }, [currentLoanProductId]);

  const renderGenderOptions = () => {
    let options = [];

    options.push(
      <option key="" value="">
        -- SELECT --
      </option>
    );
    
    gender.forEach((item) => {
      options.push(
        <option key={item} value={item}>
          {item}
        </option>
      );
    });

    return options;
  };

  const renderStatusOptions = () => {
    let options = [];

    options.push(
      <option key="" value="">
        -- SELECT --
      </option>
    );
    
    status.forEach((item) => {
      options.push(
        <option key={item} value={item}>
          {item}
        </option>
      );
    });

    return options;
  };

  const renderLoanProductOptions = () => {
    let options = [];
  
    options.push(
      <option value="" key={"loan-product-select"}>
        -- SELECT --
      </option>
    );
  
    loanProducts.forEach((o, index) => {
      options.push(
        <option key={`loan-product-${o.id}-${index}`} value={o.id}>
          {o.name}
        </option>
      );
    });
  
    return options;
  };
  

  const renderCenterOptions = () => {
    let options = [];

    options.push(
      <option value="" key={"center-select"}>
        -- SELECT --
      </option>
    );

    centers.forEach((o) => {
      options.push(
        <option value={o.id} key={`center-${o.id}`}>
          {o.name}
        </option>
      );
    })

    return options;
  }

  const renderOfficerOptions = () => {
    var options = [];

    options.push(
      <option value="" key={"officer-select"}>
        -- SELECT --
      </option>
    );

    officers.forEach((o) => {
      options.push(
        <option value={o.id} key={`officer-${o.id}`}>
          {o.last_name}, {o.first_name}
        </option>
      );
    })

    return options;
  }

  const renderLoanProductTaggingOptions = () => {
    let options = [];
  
    options.push(
      <option value="" key={"loan-product-tagging-select"}>
        -- SELECT --
      </option>
    );
  
    loanProductTagging.forEach((tag) => {
      options.push(
        <option value={tag.id} key={`loan-product-tagging-${tag.id}`}>
          {tag.name}
        </option>
      );
    });
  
    return options;
  };

  return  (
    <div className="row">
      <div className="col-md-3 col-xs-12">
        <div className="form-group">
          <div className="row">
            <div className="col">
              <ToggleSwitch
                name={`current-view-rr`}
                key={`current-view-rr`}
                checked={currentView == "RR"}
                defaultChecked={currentView == "RR"}
                onChange={() => {
                  handleViewToggled("RR")
                }}
              />
              <br/>
              <label>
                RR
              </label>
            </div>
            <div className="col">
              <ToggleSwitch
                name={`current-view-aor`}
                key={`current-view-aor`}
                checked={currentView == "AOR"}
                defaultChecked={currentView == "AOR"}
                onChange={() => {
                  handleViewToggled("AOR")
                }}
              />
              <br/>
              <label>
                AoR
              </label>
            </div>
            <div className="col">
              <ToggleSwitch
                name={`current-view-aor-mfi`}
                key={`current-view-aor-mfi`}
                checked={currentView == "AORMFI"}
                defaultChecked={currentView == "AORMFI"}
                onChange={() => {
                  handleViewToggled("AORMFI")
                }}
              />
              <br/>
              <label>
                AoR of MFI
              </label>
            </div>
            <div className="col">
              <ToggleSwitch
                name={`current-view-ml`}
                key={`current-view-ml`}
                checked={currentView == "ML"}
                defaultChecked={currentView == "ML"}
                onChange={() => {
                  handleViewToggled("ML")
                }}
              />
              <br/>
              <label>
                ML
              </label>
            </div>
          </div>
        </div>
      </div>
      <div className="col-md-3 col-xs-12">
        <div className="form-group">
          <label>
            Center
          </label>
          <select
            className="form-control"
            value={currentCenterId}
            onChange={handleCenterChanged}
          >
            {renderCenterOptions()}
          </select>
        </div>
      </div>
      {/* Loan Product Selection */}
      <div className="col-md-3 col-xs-12">
        <div className="form-group">
          <label>Loan Products</label>
          <select
            className="form-control"
            value={currentLoanProductId}
            onChange={(e) => {
              handleLoanProductChanged(e);
              setCurrentLoanProductTaggingId("");
            }}
          >
            {renderLoanProductOptions()}
          </select>
        </div>
      </div>

      {/* Loan Product Tagging */}
      <div className="col-md-3 col-xs-12">
        <div className="form-group">
          <label>Loan Product Tag</label>
          <select
          className="form-control"
          value={currentLoanProductTaggingId}
          onChange={(e) => {
            const selectedTagId = e.target.value;
            setCurrentLoanProductTaggingId(selectedTagId);
            handleLoanProductTaggingChanged(e);
            

            // Add console.log to see selected value
            console.log("Selected Loan Product Tag ID:", selectedTagId);
          }}
        >
            {renderLoanProductTaggingOptions()}
          </select>
        </div>
      </div>
      <div className="col-md-3 col-xs-12">
        <div className="form-group">
          <label>
            Officers
          </label>
          <select
            className="form-control"
            value={currentOfficerId}
            onChange={handleOfficerChanged}
          >
            {renderOfficerOptions()}
          </select>
        </div>
      </div>
      <div className="col-md-3 col-xs-12">
      <div className="form-group">
        <label>
          Member Status
        </label>
        <select
          className="form-control"
          value={currentStatus}
          onChange={handleStatusChanged}
        >
          {renderStatusOptions()}
        </select>
      </div>
      </div>
      <div className="col-md-3 col-xs-12">
      <div className="form-group">
        <label>Gender</label>
        <select
         className="form-control"
         value={currentGender} 
         onChange={handleGenderChanged}
         >
          {renderGenderOptions()}
        </select>
      </div>
      </div>

    </div>
  );
}
