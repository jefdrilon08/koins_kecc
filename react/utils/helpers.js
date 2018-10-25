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
