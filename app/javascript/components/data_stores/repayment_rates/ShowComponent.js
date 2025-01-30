import React, { useState, useEffect } from 'react';
import SkCubeLoading from '../../SkCubeLoading';
import Filter from './Filter';
import MasterListView from './MasterListView';
import RepaymentRatesView from './RepaymentRatesView';
import AgingOfReceivablesView from './AgingOfReceivablesView';
import AgingOfReceivablesMFIView from './AgingOfReceivablesMFIView';
import { fetchRepaymentRate } from '../../../services/RepaymentRatesService';

export default ShowComponent = (props) => {
  const [isLoading, setIsLoading]                       = useState(true);
  const [data, setData]                                 = useState(false);
  const [centers, setCenters]                           = useState([]);
  const [officers, setOfficers]                         = useState([]);
  const [loanProducts, setLoanProducts]                 = useState([]);
  const [currentOfficerId, setCurrentOfficerId]         = useState("");
  const [currentCenterId, setCurrentCenterId]           = useState("");
  const [currentLoanProductId, setCurrentLoanProductId] = useState("");
  const [currentLoanProductTaggingId, setCurrentLoanProductTaggingId] = useState("");
  const [currentView, setCurrentView]                   = useState("RR");
  const [currentStatus, setCurrentStatus]               = useState("");
  const [currentGender, setCurrentGender]               = useState("");

  const statusOptions = ["ACTIVE", "RESIGNED", "PENDING", "DELINQUENT"];
  const genderOptions = ["MALE", "FEMALE", "OTHERS"];

  let { id } = props;

  // Filter logic, now including loan product tagging
  const filterData = () => {
    let fData = {...data};

    if (currentCenterId) {
      fData.records = fData.records.filter((o) => o.center.id == currentCenterId);
    }

    if (currentOfficerId) {
      fData.records = fData.records.filter((o) => o.officer.id == currentOfficerId);
    }

    if (currentLoanProductId) {
      fData.records = fData.records.filter((o) => o.loan_product.id == currentLoanProductId);
    }

    if (currentStatus) {
      fData.records = fData.records.filter((o) => o.member.status.toLowerCase() == currentStatus.toLowerCase());
    }

    if (currentGender) {
      fData.records = fData.records.filter((o) => o.member.gender.toLowerCase() == currentGender.toLowerCase());
    }

    // Loan Product Tagging filter
    if (currentLoanProductTaggingId) {
      fData.records = fData.records.filter((o) => o.loan_product.loan_product_tagging_id == currentLoanProductTaggingId);
    }

    return fData;
  };

  // Fetch data logic
  const fetch = () => {
    const fetchData = {
      center_id: currentCenterId,
      loan_product_id: currentLoanProductId,
      officer_id: currentOfficerId,
    };

    fetchRepaymentRate(id, fetchData)
      .then((payload) => {
        const _data = payload.data.data;
        setIsLoading(false);
        setData(_data);
        setCenters(_data.centers);
        setLoanProducts(_data.loan_products);
        setOfficers(_data.officers);
      })
      .catch((payload) => {
        console.log(payload);
        alert("Something went wrong when fetching data store");
      });
  };

  useEffect(() => {
    fetch();
  }, []);

  // Handlers for updating filter state
  const handleCenterChanged = (event) => setCurrentCenterId(event.target.value);
  const handleOfficerChanged = (event) => setCurrentOfficerId(event.target.value);
  const handleLoanProductChanged = (event) => setCurrentLoanProductId(event.target.value);
  const handleLoanProductTaggingChanged = (event) => setCurrentLoanProductTaggingId(event.target.value); // Handle loan product tagging change
  const handleViewToggled = (viewName) => setCurrentView(viewName);
  const handleStatusChanged = (e) => setCurrentStatus(e.target.value);
  const handleGenderChanged = (e) => setCurrentGender(e.target.value);

  // Conditional rendering based on view
  if (isLoading) {
    return <SkCubeLoading />;
  } else if (currentView == "RR") {
    return (
      <div>
        <Filter
          currentView={currentView}
          handleViewToggled={handleViewToggled}
          centers={centers}
          officers={officers}
          status={statusOptions}
          gender={genderOptions}
          loanProducts={loanProducts}
          currentCenterId={currentCenterId}
          currentLoanProductId={currentLoanProductId}
          currentLoanProductTaggingId={currentLoanProductTaggingId}
          currentStatus={currentStatus}
          currentGender={currentGender}
          handleCenterChanged={handleCenterChanged}
          handleLoanProductChanged={handleLoanProductChanged}
          handleLoanProductTaggingChanged={handleLoanProductTaggingChanged} // Pass handler to Filter
          handleOfficerChanged={handleOfficerChanged}
          handleStatusChanged={handleStatusChanged}
          handleGenderChanged={handleGenderChanged}
        />
        <hr />
        <RepaymentRatesView data={filterData()} />
      </div>
    );
  } else if (currentView == "AOR") {
    return (
      <div>
        <Filter
          currentView={currentView}
          handleViewToggled={handleViewToggled}
          centers={centers}
          officers={officers}
          status={statusOptions}
          gender={genderOptions}
          loanProducts={loanProducts}
          currentCenterId={currentCenterId}
          currentLoanProductId={currentLoanProductId}
          currentLoanProductTaggingId={currentLoanProductTaggingId}
          currentStatus={currentStatus}
          currentGender={currentGender}
          handleCenterChanged={handleCenterChanged}
          handleLoanProductChanged={handleLoanProductChanged}
          handleLoanProductTaggingChanged={handleLoanProductTaggingChanged}
          handleOfficerChanged={handleOfficerChanged}
          handleStatusChanged={handleStatusChanged}
          handleGenderChanged={handleGenderChanged}
        />
        <hr />
        <AgingOfReceivablesView data={filterData()} />
      </div>
    );
  } else if (currentView == "AORMFI") {
    return (
      <div>
        <Filter
          currentView={currentView}
          handleViewToggled={handleViewToggled}
          centers={centers}
          officers={officers}
          status={statusOptions}
          gender={genderOptions}
          loanProducts={loanProducts}
          currentCenterId={currentCenterId}
          currentLoanProductId={currentLoanProductId}
          currentLoanProductTaggingId={currentLoanProductTaggingId}
          currentStatus={currentStatus}
          currentGender={currentGender}
          handleCenterChanged={handleCenterChanged}
          handleLoanProductChanged={handleLoanProductChanged}
          handleLoanProductTaggingChanged={handleLoanProductTaggingChanged}
          handleOfficerChanged={handleOfficerChanged}
          handleStatusChanged={handleStatusChanged}
          handleGenderChanged={handleGenderChanged}
        />
        <hr />
        <AgingOfReceivablesMFIView data={filterData()} />
      </div>
    );
  } else if (currentView == "ML") {
    return (
      <div>
        <Filter
          currentView={currentView}
          handleViewToggled={handleViewToggled}
          centers={centers}
          officers={officers}
          status={statusOptions}
          gender={genderOptions}
          loanProducts={loanProducts}
          currentCenterId={currentCenterId}
          currentLoanProductId={currentLoanProductId}
          currentLoanProductTaggingId={currentLoanProductTaggingId}
          currentStatus={currentStatus}
          currentGender={currentGender}
          handleCenterChanged={handleCenterChanged}
          handleLoanProductChanged={handleLoanProductChanged}
          handleLoanProductTaggingChanged={handleLoanProductTaggingChanged}
          handleOfficerChanged={handleOfficerChanged}
          handleStatusChanged={handleStatusChanged}
          handleGenderChanged={handleGenderChanged}
        />
        <hr />
        <MasterListView data={filterData()} />
      </div>
    );
  } else {
    return <div><p>Invalid view name: {currentView}</p></div>;
  }
};
