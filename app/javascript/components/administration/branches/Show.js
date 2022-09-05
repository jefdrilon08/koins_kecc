import React, { useState, useEffect } from "react";
import Modal from 'react-bootstrap/Modal';
import {
  MapContainer,
  Marker,
  Popup,
  TileLayer,
  useMap
} from 'react-leaflet';

export default function AdministrationBranchesShow(props) {
  const [user, setUser]                     = useState(props.user);
  const [data, setData]                     = useState(props.data);
  const [isMapModalOpen, setIsMapModalOpen] = useState(false);

  return (
    <>
      <Modal 
        show={isMapModalOpen}
        size="xl"
      >
        <Modal.Header>
          <Modal.Title>
            Setup Branch Coordinates
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <MapContainer
            center={[data.lat, data.lon]}
            zoom={13}
            scrollWheelZoom={true}
            style={{
              height: "500px"
            }}
          >
            <TileLayer
              attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />
            <Marker position={[data.lat, data.lon]}>
              <Popup>
                A pretty CSS3 popup. <br /> Easily customizable.
              </Popup>
            </Marker>
          </MapContainer>
          <hr/>
          <div className="row">
            <div className="col-md-6 col-xs-12">
              <div className="form-group">
                <label>
                  Lat
                </label>
                <input
                  className="form-control"
                  type="number"
                  value={data.lat}
                  onChange={(event) => {
                    data.lat = event.target.value;
                    setData(data);
                  }}
                />
              </div>
            </div>
            <div className="col-md-6 col-xs-12">
              <div className="form-group">
                <label>
                  Lon
                </label>
                <input
                  className="form-control"
                  type="number"
                  value={data.lon}
                  onChange={(event) => {
                    data.lon = event.target.value;
                    setData(data);
                  }}
                />
              </div>
            </div>
          </div>
          <hr/>
          <button
            className="btn btn-secondary w-100"
            onClick={() => {
              setIsMapModalOpen(false);
            }}
          >
            Close
          </button>
        </Modal.Body>
      </Modal>
      <div className="row">
        <div className="col-md-6 col-xs-12">
          <h2>
            {data.name}
          </h2>
        </div>
        <div className="col-md-6 col-xs-12 text-end">
          <button
            className="btn btn-success"
            onClick={() => {
              window.location.href=`/administration/branches/${data.id}/edit`;
            }}
          >
            <i className="bi bi-pencil me-2"/>
            Edit
          </button>
          <button
            className="btn btn-secondary ms-4"
            onClick={() => {
              setIsMapModalOpen(true);
            }}
          >
            <i className="bi bi-map me-2"/>
            Map
          </button>
        </div>
      </div>
      <hr/>
      <table className="table table-bordered table-sm">
        <tbody>
          <tr>
            <th>
              Color
            </th>
            <th style={{ backgroundColor: `${data.color}`}}>
            </th>
          </tr>
          <tr>
            <th>
              OR Prefix
            </th>
            <td>
              {data.or_prefix}
            </td>
          </tr>
          <tr>
            <th>
              OR Current Max
            </th>
            <td>
              {data.or_current_max}
            </td>
          </tr>
          <tr>
            <th>
              OR Counter
            </th>
            <td>
              {data.or_counter}
            </td>
          </tr>
          <tr>
            <th>
              AR Prefix
            </th>
            <td>
              {data.ar_prefix}
            </td>
          </tr>
          <tr>
            <th>
              AR Current Max
            </th>
            <td>
              {data.ar_current_max}
            </td>
          </tr>
          <tr>
            <th>
              AR Counter
            </th>
            <td>
              {data.ar_counter}
            </td>
          </tr>
        </tbody>
      </table>
      <hr/>
      <h5>
        Centers
      </h5>
      <hr/>
      <table className="table table-bordered table-sm">
        <thead>
          <tr>
            <th>
              Name
            </th>
            <th>
              SO
            </th>
            <th>
              Meeting Day
            </th>
            <th className="text-center">
              # Members
            </th>
          </tr>
        </thead>
        <tbody>
          {data.centers.map((center) => {
            return (
              <tr key={`center-${center.id}`}>
                <td>
                  <a href={`/administration/centers/${center.id}`}>
                    {center.name}
                  </a>
                </td>
                <td>
                  {center.user}
                </td>
                <td>
                  {center.meeting_day_display}
                </td>
                <td>
                  {center.member_count}
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </>
  )
}
