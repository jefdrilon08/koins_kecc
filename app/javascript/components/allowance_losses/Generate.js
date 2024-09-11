import React, { useState, useEffect } from "react";
import ErrorList from '../ErrorList';
import Select from 'react-select';
import { generate } from '../services/AllowanceLossesService';
import axios from 'axios';

const Generate = (props) => {
  const [dates, setDates] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState([]);
  const [dataByDate, setDataByDate] = useState({});
  const [selectedDates, setSelectedDates] = useState([]);

  useEffect(() => {
    axios.get('/api/allowance_losses/fetch')
      .then(response => setDates(response.data.date_as_of))
      .catch(error => console.error('Error fetching data!', error));
  }, []);

  const handleGenerateClick = () => {
    setIsLoading(true);
    setErrors([]);

    const payloads = selectedDates.map(date => ({ date_select: date.value }));

    Promise.all(payloads.map(payload => generate(payload, props.token)))
      .then(results => {
        const newDataByDate = {};
        results.forEach((res, index) => {
          newDataByDate[selectedDates[index].value] = res.data["data"][0]["data"]["records"];
        });
        setDataByDate(newDataByDate);
      })
      .catch(error => setErrors([error.message]))
      .finally(() => setIsLoading(false));
  };

  const handleDateChange = (selectedOptions) => {
    // Limit selection to 2 dates
    if (selectedOptions.length <= 2) {
      setSelectedDates(selectedOptions);
    }
  };

  const dateOptions = dates.map(date => ({ value: date, label: date }));

  const formatNumber = (number) => {
    return number.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  };

  const calculateClusterTotals = (cname) => {
    let totalCurrentAmount = 0;
    let totalParMonth = 0;
    let totalParYear = 0;
    let totalParGreaterYear = 0;

    cname['sato'].forEach((sname) => {
      const totalPar = sname["par_month"] + sname["par_year"] + sname["par_greater_year"];
      const portfolioLessPar = sname["principal_balance"] - totalPar;
      totalCurrentAmount += portfolioLessPar * 0.01;
      totalParMonth += sname["par_month"] * 0.35;
      totalParYear += sname["par_year"] * 0.35;
      totalParGreaterYear += sname["par_greater_year"] * 1;
    });

    return {
      totalCurrentAmount,
      totalParMonth,
      totalParYear,
      totalParGreaterYear
    };
  };

  const calculateSectorTotals = (sector) => {
    let sectorTotalCurrentAmount = 0;
    let sectorTotalParMonth = 0;
    let sectorTotalParYear = 0;
    let sectorTotalParGreaterYear = 0;

    sector.cluster.forEach((cname) => {
      const totals = calculateClusterTotals(cname);
      sectorTotalCurrentAmount += totals.totalCurrentAmount;
      sectorTotalParMonth += totals.totalParMonth;
      sectorTotalParYear += totals.totalParYear;
      sectorTotalParGreaterYear += totals.totalParGreaterYear;
    });

    return {
      sectorTotalCurrentAmount,
      sectorTotalParMonth,
      sectorTotalParYear,
      sectorTotalParGreaterYear
    };
  };

  const calculateOverallTotals = (sortedClusters) => {
    let overallTotalCurrentAmount = 0;
    let overallTotalParMonth = 0;
    let overallTotalParYear = 0;
    let overallTotalParGreaterYear = 0;

    sortedClusters.forEach((sector) => {
      const sectorTotals = calculateSectorTotals(sector);
      overallTotalCurrentAmount += sectorTotals.sectorTotalCurrentAmount;
      overallTotalParMonth += sectorTotals.sectorTotalParMonth;
      overallTotalParYear += sectorTotals.sectorTotalParYear;
      overallTotalParGreaterYear += sectorTotals.sectorTotalParGreaterYear;
    });

    return {
      overallTotalCurrentAmount,
      overallTotalParMonth,
      overallTotalParYear,
      overallTotalParGreaterYear
    };
  };

  const calculateClusterDifferences = (clusters1, clusters2) => {
    const differences = [];

    clusters1.forEach((cluster1) => {
      const cluster2 = clusters2.find((c) => c.cluster_name === cluster1.cluster_name);

      if (cluster2) {
        const totals1 = calculateClusterTotals(cluster1);
        const totals2 = calculateClusterTotals(cluster2);

        differences.push({
          cluster_name: cluster1.cluster_name,
          sato: cluster1.sato.map((sato1) => {
            const sato2 = cluster2.sato.find((s) => s.sato_name === sato1.sato_name) || {};

            const totalPar1 = sato1.par_month + sato1.par_year + sato1.par_greater_year;
            const portfolioLessPar1 = sato1.principal_balance - totalPar1;
            const currentAllowAmount1 = portfolioLessPar1 * 0.01;
            const allowParMonth1 = sato1.par_month * 0.35;
            const allowParYear1 = sato1.par_year * 0.35;
            const allowParGreaterYear1 = sato1.par_greater_year;

            const totalPar2 = (sato2.par_month || 0) + (sato2.par_year || 0) + (sato2.par_greater_year || 0);
            const portfolioLessPar2 = (sato2.principal_balance || 0) - totalPar2;
            const currentAllowAmount2 = portfolioLessPar2 * 0.01;
            const allowParMonth2 = (sato2.par_month || 0) * 0.35;
            const allowParYear2 = (sato2.par_year || 0) * 0.35;
            const allowParGreaterYear2 = sato2.par_greater_year || 0;

            return {
              sato_name: sato1.sato_name,
              currentDifference: currentAllowAmount1 - currentAllowAmount2,
              parMonthDifference: allowParMonth1 - allowParMonth2,
              parYearDifference: allowParYear1 - allowParYear2,
              parGreaterYearDifference: allowParGreaterYear1 - allowParGreaterYear2
            };
          }),
          totals: {
            totalCurrentAmountDifference: totals1.totalCurrentAmount - totals2.totalCurrentAmount,
            totalParMonthDifference: totals1.totalParMonth - totals2.totalParMonth,
            totalParYearDifference: totals1.totalParYear - totals2.totalParYear,
            totalParGreaterYearDifference: totals1.totalParGreaterYear - totals2.totalParGreaterYear
          }
        });
      }
    });

    return differences;
  };

  const calculateDifferences = (sectors1, sectors2) => {
    const differences = sectors1.map((sector1) => {
      const sector2 = sectors2.find((s) => s.sector_name === sector1.sector_name);

      if (sector2) {
        const clusterDifferences = calculateClusterDifferences(sector1.cluster, sector2.cluster);

        return {
          sector_name: sector1.sector_name,
          cluster: clusterDifferences,
          totals: calculateSectorTotalsDifference(sector1, sector2)
        };
      }

      return null;
    }).filter((diff) => diff !== null);

    return differences;
  };

  const calculateSectorTotalsDifference = (sector1, sector2) => {
    const totals1 = calculateSectorTotals(sector1);
    const totals2 = calculateSectorTotals(sector2);

    return {
      sectorTotalCurrentAmountDifference: totals1.sectorTotalCurrentAmount - totals2.sectorTotalCurrentAmount,
      sectorTotalParMonthDifference: totals1.sectorTotalParMonth - totals2.sectorTotalParMonth,
      sectorTotalParYearDifference: totals1.sectorTotalParYear - totals2.sectorTotalParYear,
      sectorTotalParGreaterYearDifference: totals1.sectorTotalParGreaterYear - totals2.sectorTotalParGreaterYear
    };
  };

  const calculateOverallDifferences = (differences) => {
    let overallCurrentDifference = 0;
    let overallParMonthDifference = 0;
    let overallParYearDifference = 0;
    let overallParGreaterYearDifference = 0;

    differences.forEach((sector) => {
      overallCurrentDifference += sector.totals.sectorTotalCurrentAmountDifference;
      overallParMonthDifference += sector.totals.sectorTotalParMonthDifference;
      overallParYearDifference += sector.totals.sectorTotalParYearDifference;
      overallParGreaterYearDifference += sector.totals.sectorTotalParGreaterYearDifference;
    });

    return {
      overallCurrentDifference,
      overallParMonthDifference,
      overallParYearDifference,
      overallParGreaterYearDifference
    };
  };

  const headerStyle = {
    backgroundColor: '#1f75fe',
    color: 'white',
    padding: '8px',
    minWidth: '150px'
  };

  const cellStyle = {
    backgroundColor: '#add8e6',
    padding: '8px',
    minWidth: '150px'
  };

  return (
    <React.Fragment>
      <h1>Generate Allowance For Impairment Losses</h1>
      <hr />
      <div>
        <label>Dates</label>
        <Select
          value={selectedDates}
          options={dateOptions}
          isMulti
          isDisabled={isLoading}
          onChange={handleDateChange}
        />
      </div>
      <button
        className="btn btn-info w-100 mt-2"
        disabled={isLoading || selectedDates.length !== 2}
        onClick={handleGenerateClick}
      >
        Generate
      </button>
      <ErrorList errors={errors} />
      <hr />
      <div className="tables-container">
        {selectedDates.map((date, idx) => {
          const dataClusterSector = dataByDate[date.value] || [];
          const sortedClusters = dataClusterSector.map((sector) => {
            sector.cluster.sort((a, b) => a.cluster_name.localeCompare(b.cluster_name));
            return sector;
          });
          const overallTotals = calculateOverallTotals(sortedClusters);

          return (
            <div key={date.value} className={`table-wrapper ${idx % 2 === 0 ? 'left-table' : 'right-table'}`}>
              <h3>{`Date: ${date.label}`}</h3>
              {sortedClusters.length > 0 && (
                <div>
                  <table className="table table-bordered" style={{ width: '100%', tableLayout: 'fixed' }}>
                    <tbody>
                      {sortedClusters.map((sector, index) => {
                        const sectorTotals = calculateSectorTotals(sector);
                        return (
                          <React.Fragment key={index}>
                            <tr>
                              <th className="text-center" colSpan="5" style={headerStyle}>{sector["sector_name"]}</th>
                            </tr>
                            {sector["cluster"].map((cluster, cindex) => {
                              const totals = calculateClusterTotals(cluster);
                              return (
                                <React.Fragment key={`${index}-${cindex}`}>
                                  <tr>
                                    <td className="text-center" colSpan="5" style={cellStyle}><strong>{cluster["cluster_name"]}</strong></td>
                                  </tr>
                                  <tr style={headerStyle}>
                                    <th className="text-center">SatO</th>
                                    <th className="text-center">Current Amount (1%)</th>
                                    <th className="text-center">PAR 1 - 30 days (35%)</th>
                                    <th className="text-center">PAR 31 - 365 days (35%)</th>
                                    <th className="text-center">PAR 365 days above (100%)</th>
                                  </tr>
                                  {cluster['sato']
                                    .sort((a, b) => a.sato_name.localeCompare(b.sato_name))
                                    .map((sname, sindex) => {
                                      const totalPar = sname["par_month"] + sname["par_year"] + sname["par_greater_year"];
                                      const portfolioLessPar = sname["principal_balance"] - totalPar;
                                      const currentAllowAmount = portfolioLessPar * 0.01;
                                      const allowParMonth = sname["par_month"] * 0.35;
                                      const allowParYear = sname["par_year"] * 0.35;
                                      const allowParGreaterYear = sname["par_greater_year"] * 1;

                                      return (
                                        <tr key={`${index}-${cindex}-${sindex}`} style={cellStyle}>
                                          <td className="text-center">{sname["sato_name"]}</td>
                                          <td className="text-end">{formatNumber(currentAllowAmount)}</td>
                                          <td className="text-end">{formatNumber(allowParMonth)}</td>
                                          <td className="text-end">{formatNumber(allowParYear)}</td>
                                          <td className="text-end">{formatNumber(allowParGreaterYear)}</td>
                                        </tr>
                                      );
                                    })}
                                  <tr style={cellStyle}>
                                    <td className="text-left"><strong>Total {cluster["cluster_name"]}</strong></td>
                                    <td className="text-end"><strong>{formatNumber(totals.totalCurrentAmount)}</strong></td>
                                    <td className="text-end"><strong>{formatNumber(totals.totalParMonth)}</strong></td>
                                    <td className="text-end"><strong>{formatNumber(totals.totalParYear)}</strong></td>
                                    <td className="text-end"><strong>{formatNumber(totals.totalParGreaterYear)}</strong></td>
                                  </tr>
                                </React.Fragment>
                              );
                            })}
                            <tr style={cellStyle}>
                              <td className="text-left"><strong>Total {sector["sector_name"]}</strong></td>
                              <td className="text-end"><strong>{formatNumber(sectorTotals.sectorTotalCurrentAmount)}</strong></td>
                              <td className="text-end"><strong>{formatNumber(sectorTotals.sectorTotalParMonth)}</strong></td>
                              <td className="text-end"><strong>{formatNumber(sectorTotals.sectorTotalParYear)}</strong></td>
                              <td className="text-end"><strong>{formatNumber(sectorTotals.sectorTotalParGreaterYear)}</strong></td>
                            </tr>
                          </React.Fragment>
                        );
                      })}
                      <tr style={headerStyle}>
                        <td className="text-left"><strong>Overall Total</strong></td>
                        <td className="text-end"><strong>{formatNumber(overallTotals.overallTotalCurrentAmount)}</strong></td>
                        <td className="text-end"><strong>{formatNumber(overallTotals.overallTotalParMonth)}</strong></td>
                        <td className="text-end"><strong>{formatNumber(overallTotals.overallTotalParYear)}</strong></td>
                        <td className="text-end"><strong>{formatNumber(overallTotals.overallTotalParGreaterYear)}</strong></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          );
        })}
        {selectedDates.length === 2 && (() => {
          const [firstDate, secondDate] = selectedDates;
          const firstDataCluster = dataByDate[firstDate.value] || [];
          const secondDataCluster = dataByDate[secondDate.value] || [];

          const differences = calculateDifferences(firstDataCluster, secondDataCluster);
          const overallDifferences = calculateOverallDifferences(differences);

          return (
            <div className="table-wrapper right-table">
              <h3>{`Difference: ${firstDate.label} vs ${secondDate.label}`}</h3>
              {differences.length > 0 && (
                <div>
                  <table className="table table-bordered" style={{ width: '100%', tableLayout: 'fixed' }}>
                    <tbody>
                      {differences.map((sector, index) => (
                        <React.Fragment key={index}>
                          <tr>
                            <th className="text-center" colSpan="5" style={headerStyle}>{sector.sector_name}</th>
                          </tr>
                          {sector.cluster.map((cluster, cindex) => (
                            <React.Fragment key={`${index}-${cindex}`}>
                              <tr>
                                <td className="text-center" colSpan="5" style={cellStyle}><strong>{cluster.cluster_name}</strong></td>
                              </tr>
                              <tr style={headerStyle}>
                                <th className="text-center">SatO</th>
                                <th className="text-center">Current Amount (1%)</th>
                                <th className="text-center">PAR 1 - 30 days (35%)</th>
                                <th className="text-center">PAR 31 - 365 days (35%)</th>
                                <th className="text-center">PAR 365 days above (100%)</th>
                              </tr>
                              {cluster.sato.map((sname, sindex) => (
                                <tr key={`${index}-${cindex}-${sindex}`} style={cellStyle}>
                                  <td className="text-center">{sname.sato_name}</td>
                                  <td className="text-end">{formatNumber(sname.currentDifference)}</td>
                                  <td className="text-end">{formatNumber(sname.parMonthDifference)}</td>
                                  <td className="text-end">{formatNumber(sname.parYearDifference)}</td>
                                  <td className="text-end">{formatNumber(sname.parGreaterYearDifference)}</td>
                                </tr>
                              ))}
                              <tr style={cellStyle}>
                                <td className="text-left"><strong>Total {cluster.cluster_name}</strong></td>
                                <td className="text-end"><strong>{formatNumber(cluster.totals.totalCurrentAmountDifference)}</strong></td>
                                <td className="text-end"><strong>{formatNumber(cluster.totals.totalParMonthDifference)}</strong></td>
                                <td className="text-end"><strong>{formatNumber(cluster.totals.totalParYearDifference)}</strong></td>
                                <td className="text-end"><strong>{formatNumber(cluster.totals.totalParGreaterYearDifference)}</strong></td>
                              </tr>
                            </React.Fragment>
                          ))}
                          <tr style={cellStyle}>
                            <td className="text-left"><strong>Total {sector.sector_name}</strong></td>
                            <td className="text-end"><strong>{formatNumber(sector.totals.sectorTotalCurrentAmountDifference)}</strong></td>
                            <td className="text-end"><strong>{formatNumber(sector.totals.sectorTotalParMonthDifference)}</strong></td>
                            <td className="text-end"><strong>{formatNumber(sector.totals.sectorTotalParYearDifference)}</strong></td>
                            <td className="text-end"><strong>{formatNumber(sector.totals.sectorTotalParGreaterYearDifference)}</strong></td>
                          </tr>
                        </React.Fragment>
                      ))}
                      <tr style={headerStyle}>
                        <td className="text-left"><strong>Overall Total Difference</strong></td>
                        <td className="text-end"><strong>{formatNumber(overallDifferences.overallCurrentDifference)}</strong></td>
                        <td className="text-end"><strong>{formatNumber(overallDifferences.overallParMonthDifference)}</strong></td>
                        <td className="text-end"><strong>{formatNumber(overallDifferences.overallParYearDifference)}</strong></td>
                        <td className="text-end"><strong>{formatNumber(overallDifferences.overallParGreaterYearDifference)}</strong></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          );
        })()}
      </div>

      <style jsx>{`
        .tables-container {
          display: flex;
          justify-content: space-between;
          gap: 20px;
        }

        .table-wrapper {
          flex: 1;
          margin: 10px;
          overflow-x: auto;
          min-width: 600px; /* Ensure each table has a minimum width */
        }

        .left-table {
          margin-right: 10px;
        }

        .right-table {
          margin-left: 10px;
        }

        th, td {
          padding: 12px; /* Increase padding for better readability */
          min-width: 150px; /* Set a minimum width for table cells */
          word-break: keep-all; /* Prevent line breaks within words */
        }

        table {
          width: 100%; /* Ensure the table takes full width */
          table-layout: auto; /* Allow table columns to resize automatically */
        }
      `}</style>
    </React.Fragment>
  );
};

export default Generate;
