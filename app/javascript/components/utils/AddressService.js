import data from './brgy.json';
import $ from "jquery";

const settings = { 
  activate_microinsurance: false,
  activate_microloans: true
}; 


export default class AddressService {
  constructor() {
  }

  static activateMicroinsurance() {
    return settings.activate_microinsurance;
  }

  static activateMicroloans() {
   return settings.activate_microloans;
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
    if (this.activateMicroinsurance()) {
      console.log(`Microinsurance is ${settings.activate_microinsurance}. Using local data (brgy.json) for KMBA Address`, );
      var regions = data.regions.map(function(o) {
        return o.name;
      });
      return Promise.resolve(regions);
    } else if (this.activateMicroloans()) {
      console.log(`Microloans is ${settings.activate_microloans} Using Falling back to API for KCOOP Address`);
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
            console.error("Error fetching regions from API:", err);
            reject(err);
          }
      });
    });
  } else {
    console.warn("Neither microinsurance nor microloans is active.");
      return Promise.reject("No active configuration for fetching regions.");
  }
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
    if (this.activateMicroinsurance()) {
      const region = data.regions.find(r => r.name === regionId);
      const provinces = region ? region.provinces.map(p => p.name) : [];
      return Promise.resolve(provinces);
    } else if (this.activateMicroloans()){
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
    if (this.activateMicroinsurance()) {

      let cities = [];
      data.regions.forEach(region => {
        region.provinces.forEach(province => {
          if (province.name === provinceId) {
            if (Array.isArray(province.cities)) {
              cities = province.cities.map(m => m.name);
            } else {
              console.warn(`No municipalities found for province: ${provinceId}`);
            }
          }
        });
      });
      return Promise.resolve(cities);
    } else if (this.activateMicroloans()) {
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
    if (this.activateMicroinsurance()) {
      let districts = [];
    data.regions.forEach(region => {
      region.provinces.forEach(province => {
        province.cities.forEach(city => {
          if (city.name === municipalityId) {
            if (Array.isArray(city.districts)) {
              districts = city.districts.map(district => ({
                name: district
              }));
            } else {
              console.warn(`No districts found for city: ${city.name}`);
            }
          }
        });
      });
    });
    return Promise.resolve(districts);
    } else if (this.activateMicroloans()){
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

}
