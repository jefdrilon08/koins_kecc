import React, { useState, useEffect } from "react";
import MembersProfileLegalDependents from "./MembersProfileLegalDependents";
import MembersProfileBeneficiaries from "./MembersProfileBeneficiaries";
import MembersProfileResignationRecords from "./MembersProfileResignationRecords";
import MembersProfileProjectType from "./MembersProfileProjectType";
import axios from 'axios';


export default function MembersProfileHome(props) {
  const [configData,     setConfigData]     = useState();
  const [regions,        setRegions]        = useState([]);
  const [provinces,      setProvinces]      = useState([]);
  const [municipalities, setMunicipalities] = useState([]);
  const [barangays,      setBarangays]      = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch configuration data
        const configResponse = await axios.get('/api/yml_values/production_values');
        setConfigData(configResponse.data);
        
        // Fetch regions data
        const regionsResponse = await axios.get('/api/v1/administration/admin_address/fetch'); 
        setRegions(regionsResponse.data);

        // Fetch province data
        const provincesResponse = await axios.get('/api/v1/administration/admin_province/fetch'); 
        setProvinces(provincesResponse.data);

        // Fetch municipality data
        const municipalitiesResponse = await axios.get('/api/v1/administration/admin_municipality/fetch'); 
        setMunicipalities(municipalitiesResponse.data);

        // Fetch barangay data
        const barangaysResponse = await axios.get('/api/v1/administration/admin_barangay/fetch'); 
        setBarangays(barangaysResponse.data);
        
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };
    
    fetchData();
  }, []);

  const getRegionName = (regionId) => {
    if (!Array.isArray(regions)) {
      console.error('Regions data is not an array or not defined:', regions);
      return 'Region not found';
    }
    const region = regions.find(r => r.id === regionId);
    return region ? region.region_name : 'Region not found';
  };

  const getProvinceName = (provinceId) => {
    if (!Array.isArray(provinces)) {
      console.error('Provinces data is not an array or not defined:', provinces);
      return 'Province not found';
    }
    const province = provinces.find(p => p.id === provinceId);
    return province ? province.province_name : 'Province not found';
  };

  const getMunicipalityName = (municipalityId) => {
    if (!Array.isArray(municipalities)) {
        console.error('Municipalities data is not an array or not defined:', municipalities);
        return 'Municipality not found';
    }
    const municipality = municipalities.find(m => m.id === municipalityId);
    return municipality ? municipality.municipality_name : 'Municipality not found';
  };

  const getBarangayName = (barangayId) => {
    if (!Array.isArray(barangays)) {
      console.error('Barangays data is not an array or not defined:', barangays);
      return 'Barangay not found';
    }
    const barangay = barangays.find(b => b.id === barangayId);
    return barangay ? barangay.barangay_name : 'Barangay not found';
  };


  return (
    <div id="semi_member_details">
      <div className="row">
        <div className="col-md-3">
          <ul className="list-group list-group-unbordered">
            {(() => {
              if(JSON.stringify(configData, null, 2) == 'true') {
                if(props.member.insurance_status == 'inforce') {
                  return (
                    <button className="btn btn-success">
                        <b>
                          INFORCE
                        </b>
                      </button>
                    )
                  }
                else if(props.member.insurance_status == 'lapsed') {
                  return (
                    <button className="btn btn-warning">
                      <b>
                        LAPSED    
                      </b>
                    </button>
                  )
                }
                else if(props.member.insurance_status == 'dormant') {
                  return (
                    <button className="btn btn-danger">
                      <b>
                        DORMANT    
                      </b>
                    </button>
                  )
                }
                else if(props.member.insurance_status == 'pending') {
                  return (
                    <button className="btn btn-light">
                      <b>
                        PENDING    
                      </b>
                    </button>
                  )
                }
              }    
            })()}
            <li className="list-group-item">
              Branch
              <div className="value text-muted">
                <b>
                  {props.branch ? props.branch.name : "N/A"}
                </b>
              </div>
            </li>
            <li className="list-group-item">
              Center
              <div className="value text-muted">
                <b>
                  {props.center ? props.center.name : "N/A"}
                </b>
              </div>
            </li>
            <li className="list-group-item">
              Status
              <div className="value text-muted">
                <b>
                  {props.member.status.toUpperCase()}
                </b>
              </div>
            </li>
            <li className="list-group-item">
              Date of Membership
              <div className="value text-muted">
                <b>
                  {props.dateOfMembership ? props.dateOfMembership : "N/A"}
                </b>
              </div>
            </li>
            {(() => {
              if(props.isResigned) {
                return (
                  <li className="list-group-item">
                    Date Resigned
                    <div className="value text-muted">
                      <b>
                        {props.dateResigned}
                      </b>
                    </div>
                  </li>
                )
              }
            })()}
            {(() => {
              if(props.previousDateResigned) {
                return (
                  <li className="list-group-item">
                    Previous Date Resigned
                    <div className="value text-muted">
                      <b>
                        {props.previousDateResigned}
                      </b>
                    </div>
                  </li>
                )
              }
            })()}
            <li className="list-group-item">
              Insurance Status
              <div className="value text-muted">
                <b>
                  {props.member.insurance_status.toUpperCase()}
                </b>
              </div>
            </li>
            {(() => {
              if(JSON.stringify(configData, null, 2) == 'false') {
                return (
                  <li className="list-group-item">
                    Membership Type
                    <div className="value text-muted">
                      <b>
                        {props.membershipType ? props.membershipType.name : "N/A"}
                      </b>
                    </div>
                  </li>
                )
              }
            })()}
            {(() => {
              if(JSON.stringify(configData, null, 2) == 'false') {
                return (
                  <li className="list-group-item">
                    Arrangement
                    <div className="value text-muted">
                      <b>
                        {props.membershipArrangement ? props.membershipArrangement.name : "N/A"}
                      </b>
                    </div>
                  </li>
                )
              }
            })()}
            {(() => {
              if(props.member.data["reinstatement"] == null) {
                return (
                  <li className="list-group-item">
                    Recognition Date
                    <div className="value text-muted">
                      <b>
                        {props.recognitionDate ? props.recognitionDate : "N/A"}
                      </b>
                    </div>
                  </li>
                )
              }
              return (
                  <li className="list-group-item">
                    Reinstatement Date
                    <div className="value text-muted">
                      <b>
                        {props.data.reinstatement.reinstatement_date}
                      </b>
                    </div>
                  </li>
              )
            })()}    
            <li className="list-group-item">
              Length of Stay (MBA)
              <div className="value text-muted">
                <b>
                  {props.lengthOfStay ? props.lengthOfStay : "N/A"}
                </b>
              </div>
            </li>
              {(() => {
              if(JSON.stringify(configData, null, 2) == 'true')  {
                return (
                  <li className="list-group-item">
                    Face Amount
                    <div className="value text-muted">
                      <b>
                        {props.faceAmount ? props.faceAmount: "N/A"}
                      </b>
                    </div>
                  </li>
                )
              }
            })()}
            <li className="list-group-item">
              Resolution Number
              <div className="value text-muted">
                <b>
                  {props.member.status === "active" && props.member.data.new_reso ? 
  (props.member.data.new_reso.resolution_number ? 
    props.member.data.new_reso.resolution_number : "N/A") 
  : (props.member.status === "resigned" && props.member.data.resigned_reso ?
    (props.member.data.resigned_reso.resolution_number ?
      props.member.data.resigned_reso.resolution_number : "N/A")
    : "N/A")
}
                </b>
              </div>
            </li>
            <li className="list-group-item">
            Sms Status
            <div className="value text-muted">
              <b style={{ color: props.member.data?.sms_record?.sms_rec ? "green" : "inherit" }}>
                {props.member.data?.sms_record?.sms_rec !== undefined &&
                new Date(props.member.data.sms_record.loan_maturity) > new Date() 
                  ? props.member.data.sms_record.sms_rec.toString().toUpperCase()
                  : "N/A"}
              </b>
            </div>
          </li>
          </ul>
        </div>
        <div className="col-md-9">
          <table id="profile-table" className="table table-bordered table-responsive">
            <thead>
            </thead>
            <tbody>
              <tr>
                <th>
                  Pangalan
                </th>
                <td>
                  {props.member.last_name}, {props.member.first_name} {props.member.middle_name}
                </td>
              </tr>
              <tr>
                <th>
                  Mother Maiden Name
                </th>
                <td>
                  {props.data.mothers_middle_name}
                </td>
              </tr>
              <tr>
                <th>
                  Identification Number
                </th>
                <td>
                  {props.member.identification_number}
                </td>
              </tr>
              <tr>
                <th>
                  Kasarian
                </th>
                <td>
                  {props.member.gender.toUpperCase()}
                </td>
              </tr>
              <tr>
                <th>
                  Edad
                </th>
                <td>
                  {props.memberAge}
                </td>
              </tr>
              <tr>
                <th>
                  Kapanganakan
                </th>
                <td>
                  {props.dateOfBirth}
                </td>
              </tr>
              <tr>
                <th>
                  Address
                </th>
                <td>
                {props.data.address["street"]} &nbsp;
                {getBarangayName(props.data.address["district"])} &nbsp;
                {getMunicipalityName(props.data.address["city"])} &nbsp;
                {getProvinceName(props.data.address["province"])} &nbsp;
                {getRegionName(props.data.address["region"])} &nbsp;
                </td>
              </tr>
              <tr>
                <th>
                  Numero ng Mobile
                </th>
                <td>
                  {props.member.mobile_number}
                </td>
              </tr>
              <tr>
                <th>
                  Numero ng Telepono
                </th>
                <td>
                  {props.member.home_number}
                </td>
              </tr>
              <tr>
                <th>
                  Katayuang Sibil
                </th>
                <td>
                  {props.member.civil_status}
                </td>
              </tr>
              <tr>
                <th>
                  Relihiyon
                </th>
                <td>
                  {props.member.religion}
                </td>
              </tr>
              <tr>
                <th>
                  Lugar ng Kapanganakan
                </th>
                <td>
                  {props.member.place_of_birth}
                </td>
              </tr>
              <tr>
                <th>
                  PHILHEALTH #
                </th>
                <td>
                  {props.data.government_identification_numbers.phil_health_number}
                </td>
              </tr>
              <tr>
                <th>
                  PAG-IBIG #
                </th>
                <td>
                  {props.data.government_identification_numbers.pag_ibig_number}
                </td>
              </tr>
              <tr>
                <th>
                  SSS #
                </th>
                <td>
                  {props.data.government_identification_numbers.sss_number}
                </td>
              </tr>
              <tr>
                <th>
                  TIN #
                </th>
                <td>
                  {props.data.government_identification_numbers.tin_number}
                </td>
              </tr>
              {(() => {
                if(props.member.data["reinstatement"] != null) {
                  return (
                    <tr>
                      <th>
                        Is Reinstated
                      </th>
                      <td>
                        YES
                      </td>
                    </tr>
                  )
                }
                return (
                    <tr>
                      <th>
                        Is Reinstated
                      </th>
                      <td>
                        NO
                      </td>
                    </tr>
                  )
              })()}
              {(() => {
                if(props.member.data["reinstatement"] != null) {
                  return (
                    <tr>
                      <th>
                        Reinstatement Date
                      </th>
                      <td>
                        {props.data.reinstatement.reinstatement_date}
                      </td>
                    </tr>
                  )
                }
              })()}
              {(() => {
                if(props.member.data["reinstatement"] != null) {
                  return (
                    <tr>
                      <th>
                        Old Recognition Date
                      </th>
                      <td>
                        {props.data.reinstatement.old_recognition_date}
                      </td>
                    </tr>
                  )
                }
              })()}
              {(() => {
                if(props.member.data["is_reclassified"] != null) {
                  return (
                    <tr>
                      <th>
                        Is Reclassified
                      </th>
                      <td>
                        YES
                      </td>
                    </tr>
                  )
                }
                return (
                    <tr>
                      <th>
                        Is Reclassified
                      </th>
                      <td>
                        NO
                      </td>
                    </tr>
                  )
              })()}
            </tbody>
          </table>
        </div>
      </div>
      <hr/>
      <div className="row">
        <div className="col">
          <h3 className="text-muted">
            Project Type
          </h3>
          <MembersProfileProjectType
            records={props.projectType}
          />
          <hr/>
          <h3 className="text-muted">
            Legal Dependents
          </h3>
          <MembersProfileLegalDependents
            records={props.legalDependents}
          />
          <hr/>
          <h3 className="text-muted">
            Beneficiaries
          </h3>
          <MembersProfileBeneficiaries
            records={props.beneficiaries}
          />
          <hr/>
          <h3 className="text-muted">
            Resignation Records
          </h3>
          <MembersProfileResignationRecords
            records={props.resignationRecords}
          />
        </div>
      </div>
    </div>
  )
}
