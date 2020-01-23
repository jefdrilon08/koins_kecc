//= require_directory ./lib

CalamityClaimReport = (function() {
  var $downloadBtn       = $("#download-btn");
  var $startDate         = $("#start-date");
  var $endDate           = $("#end-date");
  var $branchSelect      = $("#select-branch");
  var $clusterSelect     = $("#cluster-select");
  var urlClusters        = "/api/v1/clusters";
  var _authenticityToken;
  var clusters  = [];

  var encodeQueryData = function(data) {
    var ret = []
    for(var d in data) {
      ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
    }

    return ret.join("&");
  };
  
  var _cacheDom = function() {
    $branchSelect      = $("#select-branch");
    $clusterSelect     = $("#cluster-select");
  };


  var _bindEvents = function() {

    $clusterSelect.on("change", function() {
      var clusterId  = $(this).val();

      $branchSelect.html("");
      $branchSelect.append("<option>--ALL--</option>")
      for(var i = 0; i < clusters.length; i++) {
        if(clusters[i].id == clusterId) {
          for(var j = 0; j < clusters[i].branches.length; j++) {
            $branchSelect.append(
              "<option value='" + clusters[i].branches[j].id + "'>" + clusters[i].branches[j].name + "</option>"
            );
          }
        }
      }
    });

    $downloadBtn.on('click', function() {
      data = {
        start_date: $startDate.val(),
        end_date: $endDate.val(),
        branch: $branchSelect.val(),
        cluster: $clusterSelect.val(),
      };

      window.location = "/reports/calamity_claim_reports?" + encodeQueryData(data);
    });

    
  };

  var init = function() {
    $.ajax({
      url: urlClusters,
      method: 'GET',
      success: function(response) {
        clusters  = response.clusters;
      },
      error: function(response) {
        console.log(response);
        alert("Error in fetching clusters");
      }
    });
    _cacheDom();
    _bindEvents();
  };

  return {
    init: init
  };
})();
