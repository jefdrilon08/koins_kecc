import React, { useState, useEffect } from "react";
import Modal from 'react-bootstrap/Modal';
import {
  MapContainer,
  Marker,
  Popup,
  TileLayer,
  useMap
} from 'react-leaflet';
import axios from "axios";

export default function MapOverview(props) {
  const [token]     = useState(props.token);
  const [centerLat, setCenterLat] = useState(props.centerLat || 14.6091);
  const [centerLon, setCenterLon] = useState(props.centerLon || 121.0223);

  return (
    <>
      <MapContainer
        center={[centerLat, centerLon]}
        zoom={13}
        scrollWheelZoom={true}
        style={{
          height: "600px"
        }}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
      </MapContainer>
      <hr/>
    </>
  )
}
