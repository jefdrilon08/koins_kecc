import data from './brgy.json';
import $ from "jquery";

export default class AddressService {
  constructor() {
  }
  
  // ===================== OLD
  // static getRegions() {
  //   var regions = [];

  //   regions = data.regions.map(function(o) {
  //               return o.name;
  //             });

  //   return regions;
  // }

  static getRegions() {
    return new Promise((resolve, reject) => {
      $.ajax({
        url:"/api/v1/administration/admin_address/fetch",
        method:'GET',
        // async: false,
        success:function(response){
            var regions = response.map(o =>  ({
              id: o.id,
              name: o.region_name
            }));
            resolve(regions);
          },
          error: function(err) {
            reject(err);
          }
      });
    });
  }

  // static getProvincesByRegion(region) {
  //   var provinces = [];

  //   data.regions.forEach(function(o) {
  //     if(o.name == region) {
  //       provinces = o.provinces.map(function(o) { return o.name });
  //     }
  //   });

  //   return provinces;
  // }

  static getProvince(regionId) {
    return new Promise((resolve, reject) => {
      $.ajax({
        url: "/api/v1/administration/admin_province/fetch",
        method: 'GET',
        success: function(response) {
          var provinces = response
            .filter(o => o.region_id === regionId)
            .map(o => ({
              id: o.id,
              name: o.province_name
          }));
          resolve(provinces);
        },
        error: function(err) {
          reject(err);
        }
      });
    });
  }

  // static getCitiesByRegionAndProvince(region, province) {
  //   var cities  = [];

  //   data.regions.forEach(function(r) {
  //     if(r.name == region) {
  //       r.provinces.forEach(function(p) {
  //         if(p.name == province) {
  //           cities = p.cities.map(function(c) { return c.name });
  //         }
  //       });
  //     }
  //   });

  //   return cities;
  // }

  static getMunicipality(provinceId) {
    return new Promise((resolve, reject) => {
      $.ajax({
        url: "/api/v1/administration/admin_municipality/fetch",
        method: 'GET',
        success: function(response) {
          var municipalities = response
            .filter(o => o.province_id === provinceId)
            .map(o => ({
              id: o.id,
              name: o.municipality_name
          }))
          resolve(municipalities);
        },
        error: function(err) {
          reject(err);
        }
      });
    });
  }

  // static getDistrictsByRegionAndProvinceAndCity(region, province, city) {
  //   var districts = [];

  //   data.regions.forEach(function(r) {
  //     if(r.name == region) {
  //       r.provinces.forEach(function(p) {
  //         if(p.name == province) {
  //           p.cities.forEach(function(c) {
  //             if(c.name == city) {
  //               districts = c.districts.map(function(d) { return d });
  //             }
  //           });
  //         }
  //       });
  //     }
  //   })

  //   return districts;
  // }

  static getDistricts(municipalityId) {
    return new Promise((resolve, reject) => {
      $.ajax({
        url: "/api/v1/administration/admin_barangay/fetch",
        method: 'GET',
        success: function(response) {
          var barangay = response
            .filter(o => o.municipality_id === municipalityId)
            .map(o => ({
              id: o.id,
              name: o.barangay_name
          }))
          resolve(barangay);
        },
        error: function(err) {
          reject(err);
        }
      });
    });
  }

}
