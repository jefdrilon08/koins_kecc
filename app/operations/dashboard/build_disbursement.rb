module Dashboard
    class BuildDisbursement
        def initialize(branches:, as_of:)
            @branches = branches
            @as_of = as_of

        end
        
        def execute!
            areas = ReadOnlyArea
            .includes(clusters: :branches)
            .where(clusters: { branches: { id: @branches.ids }})
            .order("areas.name ASC, clusters.name ASC")
            
            branch_metrics = ReadOnlyDailyBranchMetric
            .select("DISTINCT ON (branch_id) *")
            .where("branch_id IN (?) AND DATE(as_of) <= ? AND status = ?", @branches.ids, @as_of, "done")
            .order("branch_id, as_of DESC, updated_at DESC")

            # GRAND TOTAL FOR SOA LOANS
            grandTotalPrincipalPaid = 0.00
            grandTotalInterestPaid = 0.00
            grandTotalPaid = 0.00

            # GRAND TOTAL FOR SOA EXPENSES
            grandTotalDisbursementPaid = 0.00


            # OUTPUT FOR AREAS
            {
            areas: areas.map do |area|

                # AREAS TOTAL FOR SOA LOANS
                areasTotalPrincipalPaid = 0.00
                areasTotalInterestPaid = 0.00
                areasTotalPaid = 0.00

                # AREAS TOTAL FOR SOA EXPENSES
                areasTotalDisbursementPaid = 0.00

                clusters = area.clusters
                .map do |c|

                    # CLUSTER TOTAL FOR SOA LOANS
                    clusterTotalPrincipalPaid = 0.00
                    clusterTotalInterestPaid = 0.00
                    clusterTotalPaid = 0.00

                    # CLUSTER TOTAL FOR SOA EXPENSES
                    clusterTotalDisbursementPaid = 0.00

                    {
                        id:       c.id,
                        name:     c.name,
                        branches: c.branches.map { |branch| 

                                metric = branch_metrics.find{ |bm| bm.branch_id == branch.id }

                                # if(branch.id != "b9659f7e-c4d5-4b8b-be3b-508bd7c6a583") # exclude the HEAD OFFICE

                                # SOA LOANS
                                soaLoansData = DataStore.soa_loans.where(
                                "meta->>'branch_id' = ? AND DATE(end_date) <= ? AND status = ?", 
                                branch.id,
                                @as_of,
                                "done"
                                ).order('end_date DESC').first
                    
                                # BRANCHES TOTAL FOR SOA LOANS
                                totalPrincipal = 0.00
                                totalInterest = 0.00
                                totalPaid = 0.00

                                # BRANCHES START AND END DATE FOR SOA LOANS AND SOA EXPENSES
                                startDateSL = ""
                                startDateSE = ""

                                endDateSL = ""
                                endDateSE = ""

                                # SOA LOANS AND SOA EXPENSES IDs
                                soaLoansID = ""
                                soaExpensesID = ""
                    
                                if soaLoansData
                                    soaLoansID = soaLoansData.id

                                    # puts "soaLoansData: " + branch.id + " " + soaLoansData.data["records"].inspect
                                    soaLoansData.data["records"].map do |rec, irec|
                                        totalPrincipal += rec["total_principal_paid"]
                                        totalInterest += rec["total_interest_paid"]
                                    end
                                    
                                    # Branches
                                    totalPaid = totalPrincipal + totalInterest
                                    # puts branch.id + " total_principal: " + total_principal.inspect

                                    # Cluster
                                    clusterTotalPrincipalPaid += totalPrincipal
                                    clusterTotalInterestPaid += totalInterest
                                    clusterTotalPaid += totalPaid

                                    # area
                                    areasTotalPrincipalPaid += totalPrincipal
                                    areasTotalInterestPaid += totalInterest
                                    areasTotalPaid += totalPaid

                                    # grand
                                    grandTotalPrincipalPaid += totalPrincipal
                                    grandTotalInterestPaid += totalInterest
                                    grandTotalPaid += totalPaid

                                    # START AND END DATE FOR SOA LOANS
                                    startDateSL = soaLoansData.data["start_date"]
                                    endDateSL = soaLoansData.data["end_date"]
                                    
                                end



                                # SOA EXPENSES
                                soaExpensesData = DataStore.soa_expenses.where(
                                "meta->>'branch_id' = ? AND DATE(end_date) <= ? AND status = ?", 
                                branch.id,
                                @as_of,
                                "done"
                                ).order('end_date DESC').first


                                # records = soaExpensesData.data.with_indifferent_access[:records]

                                # # Get officers
                                # soaExpensesData.data["officers"] = records.select{ |o| 
                                #                             o[:officer].present? 
                                #                         }.map{ |o| o[:officer] }.uniq

                                # if params[:loan_product_id].present?
                                # records = records.select{ |o|
                                #             o[:loan_product][:id] == params[:loan_product_id]
                                #             }
                                # end

                                # if params[:center_id].present?
                                # records = records.select{ |o|
                                #             o[:center][:id] == params[:center_id]
                                #             }
                                # end

                                # if params[:officer_id].present?
                                # records = records.select{ |o|
                                #             o[:officer].present?
                                #             }.select{ |o|
                                #             o[:officer][:id] == params[:officer_id]
                                #             }
                                # end

                                # soaExpensesData.data["records"] = records
                                
                                # BRANCHES TOTAL FOR SOA EXPENSES
                                totalDisbursement = 0.00

                                if soaExpensesData
                                    soaExpensesID = soaExpensesData.id

                                    # BRANCHES TOTAL DISBURSEMENT
                                    soaExpensesData.data["records"].map do |rec, irec|
                                        totalDisbursement += rec["principal"].to_f
                                    end

                                    # CLUSTER TOTAL DISBURSEMENT
                                    clusterTotalDisbursementPaid += totalDisbursement

                                    # AREA TOTAL DISBURSEMENT
                                    areasTotalDisbursementPaid += totalDisbursement

                                    # GRANND TOTAL DISBURSEMENT
                                    grandTotalDisbursementPaid += totalDisbursement

                                    # START AND END DATE FOR SOA EXPENSES
                                    startDateSE = soaExpensesData.data["start_date"]
                                    endDateSE = soaExpensesData.data["end_date"]

                                end
                                
                                
                                # OUTPUT FOR BRANCHES
                                {
                                id: branch.id,
                                name: branch.name,
                                lat: branch.lat,
                                lon: branch.lon,
                                cluster: {
                                    id: branch.cluster.id,
                                    name: branch.cluster.name
                                },
                                area: {
                                    id: branch.cluster.area.id,
                                    name: branch.cluster.area.name
                                },
                                total_principal_paid: totalPrincipal,
                                total_interest_paid: totalInterest,
                                total_paid: totalPaid,
                                total_disbursement: totalDisbursement,
                                start_date_sl: startDateSL,
                                end_date_sl: endDateSL,
                                start_date_se: startDateSE,
                                end_date_se: endDateSE,
                                soa_loans_id: soaLoansID,
                                soa_expenses_id: soaExpensesID,
                                } 
                            },
                        # CLUSTERS
                        cluster_total_principal_paid: clusterTotalPrincipalPaid,
                        cluster_total_interest_paid: clusterTotalInterestPaid,
                        cluster_total_paid: clusterTotalPaid,
                        cluster_total_disbursement: clusterTotalDisbursementPaid,

                    }

                end

                # OUTPUT FOR CLUSTERS
                { 
                    id: area.id, 
                    name: area.name, 
                    clusters: clusters, 
                    areas_total_principal_paid: areasTotalPrincipalPaid,
                    areas_total_interest_paid: areasTotalInterestPaid,
                    areas_total_paid: areasTotalPaid,
                    areas_total_disbursement: areasTotalDisbursementPaid,

                }
            end,
            grand_total_principal_paid: grandTotalPrincipalPaid,
            grand_total_interest_paid: grandTotalInterestPaid,
            grand_total_paid: grandTotalPaid,
            grand_total_disbursement: grandTotalDisbursementPaid,
            
            }
            
        end
        
        private

        def build_branch(branch_metrics, branch)
            metric = branch_metrics.find{ |bm| bm.branch_id == branch.id }

            # if(branch.id != "b9659f7e-c4d5-4b8b-be3b-508bd7c6a583") # exclude the HEAD OFFICE
            soaLoansData = DataStore.soa_loans.select("data").where(
            "meta->>'branch_id' = ?", 
            branch.id
            ).order('end_date DESC').first

            totalPrincipal = 0.00
            totalInterest = 0.00
            totalPaid = 0.00

            if soaLoansData
                # puts "soaLoansData: " + branch.id + " " + soaLoansData.data["records"].inspect

                totalPrincipal = 0.00
                totalInterest = 0.00
                soaLoansData.data["records"].map do |rec, irec|
                    totalPrincipal += rec["total_principal_paid"]
                    totalInterest += rec["total_interest_paid"]
                end

                totalPaid = totalPrincipal + totalInterest
                # puts branch.id + " total_principal: " + total_principal.inspect

            end

            {
            id: branch.id,
            name: branch.name,
            lat: branch.lat,
            lon: branch.lon,
            cluster: {
                id: branch.cluster.id,
                name: branch.cluster.name
            },
            area: {
                id: branch.cluster.area.id,
                name: branch.cluster.area.name
            },
            total_principal_paid: totalPrincipal,
            total_interest_paid: totalInterest,
            total_paid: totalPaid
            }
        end
    end
end