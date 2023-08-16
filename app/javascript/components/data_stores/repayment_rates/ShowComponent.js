import React, { useState, useEffect } from 'react';
import SkCubeLoading from '../../SkCubeLoading';
import Filter from './Filter';
import MasterListView from './MasterListView';
import RepaymentRatesView from './RepaymentRatesView';
import AgingOfReceivablesView from './AgingOfReceivablesView';

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
  const [currentView, setCurrentView]                   = useState("RR");

  let {
    id
  } = props;

  const fetch = (options) => {
    var data  = {
      center_id: currentCenterId,
      loan_product_id: currentLoanProductId,
      officer_id: currentOfficerId
    }

    console.log("fetch (data):");
    console.log(data);

    fetchRepaymentRate(id, {...data})
      .then((payload) => {
        setIsLoading(false);
        setData(payload.data);
        setCenters(payload.data.centers);
        setLoanProducts(payload.data.loan_products);
        setOfficers(payload.data.officers);
      }).catch((payload) => {
        console.log(payload);
        alert("Something went wrong when fetching data store");
      })
  }

  useEffect(() => {
    fetch();
  }, []);

  const handleCenterChanged = (event) => {
    setCurrentCenterId(event.target.value);
  }

  const handleOfficerChanged = (event) => {
    setCurrentOfficerId(event.target.value);
  }

  const handleLoanProductChanged = (event) => {
    setCurrentLoanProductId(event.target.value);
  }

  const handleViewToggled = (viewName) => {
    setCurrentView(viewName);
  }

  if (isLoading) {
    return  (
      <SkCubeLoading/>
    );
  } else if (currentView == "RR") {
    return  (
      <div>
        <Filter
          currentView={currentView} 
          handleViewToggled={handleViewToggled}
          centers={centers}
          officers={officers}
          loanProducts={loanProducts}
          currentCenterId={currentCenterId}
          currentLoanProductId={currentLoanProductId}
          handleCenterChanged={handleCenterChanged}
          handleLoanProductChanged={handleLoanProductChanged}
          handleOfficerChanged={handleOfficerChanged}
        />
        <hr/>
        <RepaymentRatesView
          data={data}
        />
      </div>
    );
  } else if(this.state.currentView == "AOR") {
    return  (
      <div>
        <Filter
          currentView={currentView} 
          handleViewToggled={handleViewToggled}
          centers={centers}
          officers={officers}
          loanProducts={loanProducts}
          currentCenterId={currentCenterId}
          currentLoanProductId={currentLoanProductId}
          handleCenterChanged={handleCenterChanged}
          handleLoanProductChanged={handleLoanProductChanged}
          handleOfficerChanged={handleOfficerChanged}
        />
        <hr/>
        <AgingOfReceivablesView
          data={data}
        />
      </div>
    );
  } else if(this.state.currentView == "ML") {
    return  (
      <div>
        <Filter
          currentView={currentView} 
          handleViewToggled={handleViewToggled}
          centers={centers}
          officers={officers}
          loanProducts={loanProducts}
          currentCenterId={currentCenterId}
          currentLoanProductId={currentLoanProductId}
          handleCenterChanged={handleCenterChanged}
          handleLoanProductChanged={handleLoanProductChanged}
          handleOfficerChanged={handleOfficerChanged}
        />
        <hr/>
        <MasterListView
          data={data}
        />
      </div>
    );
  } else {
    return  (
      <div>
        <p>
          Invalid view name: {this.state.currentView}
        </p>
      </div>
    );
  }
}
