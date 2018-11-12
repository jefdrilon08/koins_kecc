export function buildBillingTableData(o) {
  var data  = [];

  for(var i = 0; i < o.data.records.length; i++) {
    // Loan products
    data.push({
    });

    // Deposits

    // Insurance

    // Withdraw payments
  }

  return data;
}

export function numberAsPercent(x) {
  x = ((Math.round(x * 100) / 100) * 100).toFixed(2);

  return x + "%";
}

export function numberWithCommas(x) {
  x = (Math.round(x * 100) / 100).toFixed(2);

  if(x < 0) {
    x = x * -1; 
    x = "(" + x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + ")";
  } else {
    x = x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }   

  return x;
}

export function getReligionOptions() {
  var religions = [
    "Roman Catholic", 
    "Other Christian", 
    "Members Church of God International", 
    "Iglesia ni Cristo", 
    "Protestant", 
    "Jehovah's Witnesses", 
    "Seventh-day Adventist Church", 
    "Muslim", 
    "Aglipayan", 
    "Seventh Day Baptist Church", 
    "Church of God", 
    "Jesus Miracle Crusade International Ministry", 
    "Pentecostal Missionary Church of Christ", 
    "Assemblies of God", 
    "The Church of Jesus Christ of Latter-day Saints", 
    "Sta. Iglesia Rosa Mistica Inc.", 
    "United Pentecostal Church International", 
    "Evangelical", 
    "Most Holy Church of God in Jesus Christ"
  ]

  var data = [];

  for(var i = 0; i < religions.length; i++) {
    data.push({
      value: religions[i],
      label: religions[i]
    });
  }

  return data;
}
