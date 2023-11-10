import React, { useEffect, useState } from 'react';
import axios from 'axios';
import SkCubeLoading from '../SkCubeLoading';

function Disbursement(props) {
    const token = props.token;

    const [isLoading, setIsLoading] = useState(true);
    const [isFetching, setIsFetching] = useState(false);

    const [asOf, setAsOf] = useState("");

    const [data, setData] = useState(false);

    const fetch = async () => {
        
        let res = await axios.get(
            '/api/dashboard/disbursement?as_of=' + asOf,
            {
                headers: {
                    "X-KOINS-HQ-TOKEN": token
                }
            }
        ).catch((error) => {
            console.log(error);
            alert("Error in fetching dashboard overview");
        })

        // REMOVE HEAD OFFICE FOR DISBURSEMENT
        // const data = res.data
        // const removedHO = data.filter(data => {
        //     return data.areas.id !== 'b9659f7e-c4d5-4b8b-be3b-508bd7c6a583';
        // });
        //console.log("res.data: ", res.data);
        if (res.status === 200) {
            //console.log("res.data: ", res.data.areas);
            //data = res.data;
            //responseData = res.data;
            setData(res.data);

            setIsLoading(false);
            setIsFetching(false);
        }

    }

    function handleSyncClicked() {
        setIsFetching(true);
        //console.log("as_of: ", asOf);
        fetch();
    }

    function handleAsOfChanged(event) {
        setAsOf(event.target.value);
        //console.log("as_of: ", asOf);
    }

    var colSpan = 4;

    // COLORS
    const areaColor = "#bad5fd";
    const totalColor = "#c5ffc1";
    const branchColor = "#797979";
    const clusterColor = "#f3cf99";

    const borderColor = "#dee2e6";

    useEffect(() => {
        fetch();

    }, []);

    return (
        <>
            {isLoading ? (
                <div>
                    <SkCubeLoading />
                    <center>
                        <h6>
                            Loading Overview...
                        </h6>
                    </center>
                </div>
            ) : (
                <>
                    <div className="row">
                        <div className="col-md-10 col-xs-12">
                            <div className="form-group">
                                <input
                                    type="date"
                                    className="form-control"
                                    disabled={isFetching}
                                    //disabled={true}
                                    value={asOf}
                                    onChange={e => handleAsOfChanged(e)}
                                />
                            </div>
                        </div>
                        <div className="col-md-2 col-xs-12">
                            <div className="d-grid gap-2">
                                <button
                                    className="btn btn-primary btn-block"
                                    disabled={isFetching}
                                    //disabled={true}
                                    onClick={handleSyncClicked}
                                >
                                    <span className="bi bi-arrow-repeat" />
                                    Sync
                                </button>
                            </div>
                        </div>
                    </div>
                    <hr />
                    {isFetching ? (
                            <div>
                                <SkCubeLoading />
                                <center>
                                    <h6>
                                        Loading Overview...
                                    </h6>
                                </center>
                            </div>
                        ):(
                            <div className="table-responsive">
                                <table className="table table-sm table-bordered">
                                    <tbody>

                                        {data.areas.map((areas, areasIndex) => {
                                            // console.log("updated data: ", this.state.data);
                                            return (
                                                <>

                                                    {/* AREA HEADER */}
                                                    <tr key={"area-" + areas.id} style={{ backgroundColor: areaColor }}>
                                                        <th className="text-center" colSpan={colSpan}>
                                                            {areas.name}
                                                        </th>
                                                    </tr>
                                                    {/* CLUSTER HEADERS */}
                                                    {areas.clusters.map((clusters, clustersIndex) => {
                                                        return (
                                                            <>

                                                                <tr key={"cluster-" + clusters.id} style={{ backgroundColor: clusterColor }}>
                                                                    <th className="text-center" colSpan={colSpan}>
                                                                        {clusters.name}
                                                                    </th>
                                                                </tr>

                                                                {/* HEADERS */}
                                                                <tr key={"header-" + clusters.id} style={{ backgroundColor: branchColor, color: "white" }}>
                                                                    <th className="text-center" style={{ width: "15%", verticalAlign: "middle" }}>
                                                                        Sato
                                                                    </th>
                                                                    {/* DISBURSEMENT TAB */}
                                                                    <th className="text-center" style={{ width: "25%", verticalAlign: "middle" }}>
                                                                        <table style={{ width: "100%" }}>
                                                                            <tr>
                                                                                <th className="text-center" style={{ borderBottom: "0.5px solid", borderColor: borderColor }} colSpan={colSpan}>
                                                                                    Disbursement
                                                                                </th>
                                                                            </tr>
                                                                            <tr>
                                                                                <th className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor,  width: "50%" }}>
                                                                                    Principal
                                                                                </th>
                                                                                <th className="text-center" style={{ width: "50%" }}>
                                                                                    As Of
                                                                                </th>
                                                                            </tr>
                                                                        </table>
                                                                    </th>

                                                                    {/* COLLECTION TAB */}
                                                                    <th className="text-center" style={{ width: "60%" }}>
                                                                        <table style={{ width: "100%" }}>
                                                                            <tbody>
                                                                                <tr>
                                                                                    <th className="text-center" style={{ borderBottom: "0.5px solid", borderColor: borderColor }} colSpan={colSpan}>
                                                                                        Collection
                                                                                    </th>
                                                                                </tr>

                                                                                <tr>
                                                                                    <th className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                        Principal
                                                                                    </th>
                                                                                    <th className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                        Interest
                                                                                    </th>
                                                                                    <th className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                        Total
                                                                                    </th>
                                                                                    <th className="text-center" style={{ width: "25%"}}>
                                                                                        As Of
                                                                                    </th>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>

                                                                    </th>
                                                                    

                                                                </tr>
                                                                {/* DATA BRANCH ROW */}
                                                                {clusters.branches.map((branches, branchesIndex) => {
                                                                    return (
                                                                        <>

                                                                            <tr key={"branch-" + branches.id} >
                                                                                <td>
                                                                                    <strong>
                                                                                        {/* Branch Name */}
                                                                                        {branches.name}
                                                                                    </strong>
                                                                                </td>
                                                                                <td className="text-center">
                                                                                    <table style={{ width: "100%" }}>
                                                                                        <tbody>
                                                                                            <tr>
                                                                                                <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "50%" }}>
                                                                                                        
                                                                                                        {/* Disbursement Principal Branches */}
                                                                                                        {branches.total_disbursement.toLocaleString('en-PH', {
                                                                                                            //style: 'currency',
                                                                                                            //currency: 'PHP',
                                                                                                            maximumFractionDigits: 2,
                                                                                                        })}
                                                                                                    
                                                                                                </td>

                                                                                                <td className="text-center" style={{ width: "50%" }}>
                                                                                                        {/* Disbursement As Of Branches */}
                                                                                                        {branches.end_date_se}
                                                                                                </td>
                                                                                            </tr>
                                                                                        </tbody>
                                                                                    </table>
                                                                                        
                                                                                    
                                                                                </td>
                                                                                <td className="text-center">
                                                                                    <table style={{ width: "100%" }}>
                                                                                        <tbody>
                                                                                            <tr>
                                                                                                <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                                    
                                                                                                        {/* Principal */}
                                                                                                        {branches.total_principal_paid.toLocaleString('en-PH', {
                                                                                                            //style: 'currency',
                                                                                                            //currency: 'PHP',
                                                                                                            maximumFractionDigits: 2,
                                                                                                        })}
                                                                                                    
                                                                                                </td>
                                                                                                <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                                    
                                                                                                        {/* Interest */}
                                                                                                        {branches.total_interest_paid.toLocaleString('en-PH', {
                                                                                                            //style: 'currency',
                                                                                                            //currency: 'PHP',
                                                                                                            maximumFractionDigits: 2,
                                                                                                        })}
                                                                                                    
                                                                                                </td>
                                                                                                <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                                    
                                                                                                        {/* Total */}
                                                                                                        {branches.total_paid.toLocaleString('en-PH', {
                                                                                                            //style: 'currency',
                                                                                                            //currency: 'PHP',
                                                                                                            maximumFractionDigits: 2,
                                                                                                        })}
                                                                                                    
                                                                                                </td>
                                                                                                <td className="text-center" style={{ width: "25%" }}>
                                                                                                        {/* As Of BRANCHES */}
                                                                                                        {branches.end_date_sl}
                                                                                                </td>
                                                                                            </tr>
                                                                                        </tbody>
                                                                                    </table>
                                                                                </td>
                                                                                
                                                                            </tr>
                                                                        </>
                                                                    )
                                                                })} {/* END OF DATA BRANCH ROW */}


                                                                {/* CLUSTER TOTAL ROW*/}
                                                                <tr key={"cluster-total"} style={{ backgroundColor: totalColor }}>
                                                                    <td>
                                                                        <strong>
                                                                            {/* Cluster Name Total */}
                                                                            {clusters.name + " Total"}
                                                                        </strong>
                                                                    </td>
                                                                    <td className="text-center">
                                                                        <table style={{ width: "100%" }}>
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "50%" }}>
                                                                                            
                                                                                        <strong>
                                                                                            {/* CLUSTER Disbursement PrincipalTotal */}
                                                                                            {clusters.cluster_total_disbursement.toLocaleString('en-PH', {
                                                                                                //style: 'currency',
                                                                                                //currency: 'PHP',
                                                                                                maximumFractionDigits: 2,
                                                                                            })}
                                                                                        </strong>
                                                                                        
                                                                                    </td>

                                                                                    <td className="text-center" style={{ width: "50%" }}>
                                                                                            {/* CLUSTER Disbursement As Of */}
                                                                                    </td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                        
                                                                    </td>
                                                                    <td className="text-center">
                                                                        <table style={{ width: "100%" }}>
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                        <strong>
                                                                                            {/* Cluster Principal Total */}
                                                                                            {clusters.cluster_total_principal_paid.toLocaleString('en-PH', {
                                                                                                //style: 'currency',
                                                                                                //currency: 'PHP',
                                                                                                maximumFractionDigits: 2,
                                                                                            })}
                                                                                        </strong>
                                                                                    </td>
                                                                                    <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                        <strong>
                                                                                            {/* Cluster Interest Total */}
                                                                                            {clusters.cluster_total_interest_paid.toLocaleString('en-PH', {
                                                                                                //style: 'currency',
                                                                                                //currency: 'PHP',
                                                                                                maximumFractionDigits: 2,
                                                                                            })}
                                                                                        </strong>
                                                                                    </td>
                                                                                    <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                                        <strong>
                                                                                            {/* Cluster Total Total */}
                                                                                            {clusters.cluster_total_paid.toLocaleString('en-PH', {
                                                                                                //style: 'currency',
                                                                                                //currency: 'PHP',
                                                                                                maximumFractionDigits: 2,
                                                                                            })}
                                                                                        </strong>
                                                                                    </td>
                                                                                    <td className="text-center" style={{ width: "25%" }}>
                                                                                            {/* CLUSTER COLLECTION As Of */}
                                                                                            
                                                                                    </td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>

                                                                    </td>
                                                                </tr>
                                                            </>
                                                        )
                                                    })}  {/* END OF CLUSTER */}

                                                    {/* AREA TOTAL ROW */}
                                                    <tr key={"area-total"} style={{ backgroundColor: areaColor }}>
                                                        <td>
                                                            <strong>
                                                                {/* Area Name Total */}
                                                                {areas.name + " Total"}
                                                            </strong>
                                                        </td>
                                                        <td className="text-center">
                                                            <table style={{ width: "100%" }}>
                                                                <tbody>
                                                                    <tr>
                                                                        <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "50%" }}>
                                                                                
                                                                            <strong>
                                                                                {/* Area Disbursement Total */}
                                                                                {areas.areas_total_disbursement.toLocaleString('en-PH', {
                                                                                    //style: 'currency',
                                                                                    //currency: 'PHP',
                                                                                    maximumFractionDigits: 2,
                                                                                })}
                                                                            </strong>
                                                                            
                                                                        </td>

                                                                        <td className="text-center" style={{ width: "50%" }}>
                                                                                {/* Area Disbursement As Of */}
                                                                                <strong>

                                                                                </strong>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                            
                                                        </td>
                                                        <td className="text-center">
                                                            <table style={{ width: "100%" }}>
                                                                <tbody>
                                                                    <tr>
                                                                        <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                            <strong>
                                                                                {/* Area Principal Total */}
                                                                                {areas.areas_total_principal_paid.toLocaleString('en-PH', {
                                                                                    //style: 'currency',
                                                                                    //currency: 'PHP',
                                                                                    maximumFractionDigits: 2,
                                                                                })}
                                                                            </strong>
                                                                        </td>
                                                                        <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                            <strong>
                                                                                {/* Area Interest Total */}
                                                                                {areas.areas_total_interest_paid.toLocaleString('en-PH', {
                                                                                    //style: 'currency',
                                                                                    //currency: 'PHP',
                                                                                    maximumFractionDigits: 2,
                                                                                })}
                                                                            </strong>
                                                                        </td>
                                                                        <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                            <strong>
                                                                                {/* Area Total Total */}
                                                                                {areas.areas_total_paid.toLocaleString('en-PH', {
                                                                                    //style: 'currency',
                                                                                    //currency: 'PHP',
                                                                                    maximumFractionDigits: 2,
                                                                                })}
                                                                            </strong>
                                                                        </td>
                                                                        <td className="text-center" style={{ width: "25%" }}>
                                                                            <strong>
                                                                                {/* Area As Of */}
                                                                            </strong>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>

                                                        </td>
                                                        
                                                    </tr>
                                                    <br />

                                                </>
                                            )
                                        })} {/* END OF AREA */}

                                        {/* GRAND TOTAL */}
                                        <tr key={"grand-total"} style={{ backgroundColor: "#000", color: "#fff" }}>
                                            <td>
                                                <strong>
                                                    {/* Grand Total */}
                                                    Grand Total
                                                </strong>
                                            </td>
                                            <td className="text-center">
                                                <table style={{ width: "100%" }}>
                                                    <tbody>
                                                        <tr>
                                                            <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "50%" }}>
                                                                    
                                                                <strong>
                                                                    {/* Grand Disbursement Total */}
                                                                    {data.grand_total_disbursement.toLocaleString('en-PH', {
                                                                        //style: 'currency',
                                                                        //currency: 'PHP',
                                                                        maximumFractionDigits: 2,
                                                                    })}
                                                                </strong>
                                                                
                                                            </td>

                                                            <td className="text-center" style={{ width: "50%" }}>
                                                                    {/* Grand Disbursement As Of */}
                                                                    <strong>

                                                                    </strong>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                                
                                            </td>
                                            <td className="text-center">
                                                <table style={{ width: "100%" }}>
                                                    <tbody>
                                                        <tr>
                                                            <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                <strong>
                                                                    {/* Grand Principal Total */}
                                                                    {data.grand_total_principal_paid.toLocaleString('en-PH', {
                                                                        //style: 'currency',
                                                                        //currency: 'PHP',
                                                                        maximumFractionDigits: 2,
                                                                    })}
                                                                </strong>
                                                            </td>
                                                            <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                <strong>
                                                                    {/* Grand Interest Total */}
                                                                    {data.grand_total_interest_paid.toLocaleString('en-PH', {
                                                                        //style: 'currency',
                                                                        //currency: 'PHP',
                                                                        maximumFractionDigits: 2,
                                                                    })}
                                                                </strong>
                                                            </td>
                                                            <td className="text-center" style={{ borderRight: "0.5px solid", borderColor: borderColor, width: "25%" }}>
                                                                <strong>
                                                                    {/* Grand Total Total */}
                                                                    {data.grand_total_paid.toLocaleString('en-PH', {
                                                                        //style: 'currency',
                                                                        //currency: 'PHP',
                                                                        maximumFractionDigits: 2,
                                                                    })}
                                                                </strong>
                                                            </td>
                                                            <td className="text-center" style={{ width: "25%" }}>
                                                                <strong>
                                                                    {/* Grand As Of */}
                                                                </strong>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>

                                            </td>
                                        </tr>

                                    </tbody>
                                </table>
                            </div>
                        )
                    }
                    
                </>
            )}
        </>

    )
}

export default Disbursement