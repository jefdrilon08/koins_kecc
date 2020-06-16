module Dashboard
  class BuildOverviewMii
    def initialize(branches:, as_of:)
      @branches = branches
      @as_of = as_of
    end

    def execute!
      areas = Area
        .includes(clusters: :branches)
        .where(clusters: { branches: { id: @branches.ids }})
        .order("areas.name ASC, clusters.name ASC")

      data_stores = DataStore
        .select("DISTINCT ON (meta->>'data_store_type', meta->>'branch_id') *")
        .where("meta->>'data_store_type' IN (?) AND meta->>'branch_id' IN (?) AND DATE(meta->>'as_of') <= ?", %w[CLAIMS_COUNTS PERSONAL_FUNDS INSURANCE_MEMBER_COUNTS], @branches.ids, @as_of)
        .order("meta->>'data_store_type', meta->>'branch_id', DATE(meta->>'as_of') DESC")

      {
        areas: areas.map do |area|
          clusters = area.clusters
            .map do |c|
              {
                id:       c.id,
                name:     c.name,
                branches: c.branches.map { |b| build_branch(data_stores, b) }
              }
            end
          { id: area.id, name: area.name, clusters: clusters }
        end
      }
    end

    private

    def build_branch(data_stores, branch)
      mc = data_stores.find { |ds| ds.meta["branch_id"] == branch.id && ds.meta["data_store_type"] == "INSURANCE_MEMBER_COUNTS" }
      pf = data_stores.find { |ds| ds.meta["branch_id"] == branch.id && ds.meta["data_store_type"] == "PERSONAL_FUNDS" }
      cc = data_stores.find { |ds| ds.meta["branch_id"] == branch.id && ds.meta["data_store_type"] == "CLAIMS_COUNTS" }

      d = {
        personal_funds_as_of: "",
        member_counts_as_of: "",
        claims_counts_as_of: "",
        total_life: 0.00,
        total_rf: 0.00,
        total_life_rf: 0.00,
        active_members:           { male: 0, female: 0, others: 0, total: 0 },
        inforce_members:          { male: 0, female: 0, others: 0, total: 0 },
        lapsed_members:           { male: 0, female: 0, others: 0, total: 0 },
        pending_members:          { male: 0, female: 0, others: 0, total: 0 },
        dormant_members:          { male: 0, female: 0, others: 0, total: 0 },
        resigned_active_members:  { male: 0, female: 0, others: 0, total: 0 },
        approved_claims:          { 
                                    blip: 0,
                                    clip: 0,
                                    hiip: 0,
                                    kjsp: 0,
                                    calamity_assistance: 0,
                                    k_bente: 0,
                                    k_kalinga: 0,
                                    total: 0,
                                   },
        total_claims_amount: 0.00,
        total_blip_claims: 0.00,
        total_clip_claims: 0.00,
        total_hiip_claims: 0.00,
        total_kbente_claims: 0.00,
        total_kkalinga_claims: 0.00,
        total_kjsp_claims: 0.00,
        total_calamity_assistance_claims: 0.00,
        total_blip_kcoop: 0,
        total_blip_capsr: 0,
        total_blip_associate: 0,
        total_blip_jvo: 0,
        total_blip_kcoop_amount: 0.00,
        total_blip_capsr_amount: 0.00,
        total_blip_associate_amount: 0.00,
        total_blip_jvo_amount: 0.00,
        total_clip_kcoop: 0,
        total_clip_capsr: 0,
        total_clip_associate: 0,
        total_clip_jvo: 0,
        total_clip_kcoop_amount: 0.00,
        total_clip_capsr_amount: 0.00,
        total_clip_associate_amount: 0.00,
        total_clip_jvo_amount: 0.00,
        total_hiip_kcoop: 0,
        total_hiip_capsr: 0,
        total_hiip_associate: 0,
        total_hiip_jvo: 0,
        total_hiip_kcoop_amount: 0.00,
        total_hiip_capsr_amount: 0.00,
        total_hiip_associate_amount: 0.00,
        total_hiip_jvo_amount: 0.00,
        total_kbente_kcoop: 0,
        total_kbente_capsr: 0,
        total_kbente_associate: 0,
        total_kbente_jvo: 0,
        total_kbente_kcoop_amount: 0.00,
        total_kbente_capsr_amount: 0.00,
        total_kbente_associate_amount: 0.00,
        total_kbente_jvo_amount: 0.00,
        total_kjsp_kcoop: 0,
        total_kjsp_capsr: 0,
        total_kjsp_associate: 0,
        total_kjsp_jvo: 0,
        total_kjsp_kcoop_amount: 0.00,
        total_kjsp_capsr_amount: 0.00,
        total_kjsp_associate_amount: 0.00,
        total_kjsp_jvo_amount: 0.00,
        total_kkalinga_kcoop: 0,
        total_kkalinga_capsr: 0,
        total_kkalinga_associate: 0,
        total_kkalinga_jvo: 0,
        total_kkalinga_kcoop_amount: 0.00,
        total_kkalinga_capsr_amount: 0.00,
        total_kkalinga_associate_amount: 0.00,
        total_kkalinga_jvo_amount: 0.00,
        total_calamity_assistance_kcoop: 0,
        total_calamity_assistance_capsr: 0,
        total_calamity_assistance_associate: 0,
        total_calamity_assistance_jvo: 0,
        total_calamity_assistance_kcoop_amount: 0.00,
        total_calamity_assistance_capsr_amount: 0.00,
        total_calamity_assistance_associate_amount: 0.00,
        total_calamity_assistance_jvo_amount: 0.00,
        area: "",
      }

      if pf.present?
        d[:personal_funds_as_of] = pf.meta["as_of"]

        pf.data["records"].each.with_index do |p, i|
          d[:total_life_rf] += p["total"].to_f.round(2)

          if !p["accounts"].nil?
            d[:total_rf] += p["accounts"].select{ |acc| acc["account_subtype"] == "Retirement Fund" }.first["balance"].to_f.round(2)
            d[:total_life] += p["accounts"].select{ |acc| acc["account_subtype"] == "Life Insurance Fund" }.first["balance"].to_f.round(2)
          end
        end
      end

      if cc.present?
        counts = cc.data["counts"]
        area = cc.data["area"]

        d[:area] = area
        d[:claims_counts_as_of]  = cc.meta["as_of"]
      
        d[:approved_claims][:blip]                = counts["approved_claims"]["blip"]
        d[:approved_claims][:clip]                = counts["approved_claims"]["clip"]
        d[:approved_claims][:hiip]                = counts["approved_claims"]["hiip"]
        d[:approved_claims][:k_bente]             = counts["approved_claims"]["k_bente"]
        d[:approved_claims][:k_kalinga]           = counts["approved_claims"]["k_kalinga"]
        d[:approved_claims][:kjsp]                = counts["approved_claims"]["kjsp"]
        d[:approved_claims][:calamity_assistance] = counts["approved_claims"]["calamity_assistance"]
        d[:approved_claims][:total]               = counts["approved_claims"]["total"]

        cc.data["counts"]["approved_claims"]["claims"].each.with_index do |c, i|
            
          d[:total_claims_amount] += c["amount"].to_f.round(2)

          if c["claim_type"] == "BLIP"
            d[:total_blip_claims] += c["amount"].to_f.round(2)

            if area["name"] == "HEAD OFFICE"
              d[:total_blip_associate_amount] += c["amount"].to_f.round(2)
              d[:total_blip_associate] += 1
            elsif area["name"] == "VISAYAS"
              d[:total_blip_capsr_amount] += c["amount"].to_f.round(2)
              d[:total_blip_capsr] += 1
            elsif area["name"] == "NORTH LUZON"
              d[:total_blip_jvo_amount] += c["amount"].to_f.round(2)
              d[:total_blip_jvo] += 1
            else
              d[:total_blip_kcoop_amount] += c["amount"].to_f.round(2)
              d[:total_blip_kcoop] += 1
            end
          elsif c["claim_type"] == "CLIP"
            d[:total_clip_claims] += c["amount"].to_f.round(2)
          
            if area["name"] == "HEAD OFFICE"
              d[:total_clip_associate_amount] += c["amount"].to_f.round(2)
              d[:total_clip_associate] += 1
            elsif area["name"] == "VISAYAS"
              d[:total_clip_capsr_amount] += c["amount"].to_f.round(2)
              d[:total_clip_capsr] += 1
            elsif area["name"] == "NORTH LUZON"
              d[:total_clip_jvo_amount] += c["amount"].to_f.round(2)
              d[:total_clip_jvo] += 1
            else
              d[:total_clip_kcoop_amount] += c["amount"].to_f.round(2)
              d[:total_clip_kcoop] += 1
            end
          elsif c["claim_type"] == "HIIP"
            d[:total_hiip_claims] += c["amount"].to_f.round(2)

            if area["name"] == "HEAD OFFICE"
              d[:total_hiip_associate_amount] += c["amount"].to_f.round(2)
              d[:total_hiip_associate] += 1
            elsif area["name"] == "VISAYAS"
              d[:total_hiip_capsr_amount] += c["amount"].to_f.round(2)
              d[:total_hiip_capsr] += 1
            elsif area["name"] == "NORTH LUZON"
              d[:total_hiip_jvo_amount] += c["amount"].to_f.round(2)
              d[:total_hiip_jvo] += 1
            else
              d[:total_hiip_kcoop_amount] += c["amount"].to_f.round(2)
              d[:total_hiip_kcoop] += 1
            end
          elsif c["claim_type"] == "CALAMITY ASSISTANCE"
            d[:total_calamity_assistance_claims] += c["amount"].to_f.round(2)
          
            if area["name"] == "HEAD OFFICE"
              d[:total_calamity_assistance_associate_amount] += c["amount"].to_f.round(2)
              d[:total_calamity_assistance_associate] += 1
            elsif area["name"] == "VISAYAS"
              d[:total_calamity_assistance_capsr_amount] += c["amount"].to_f.round(2)
              d[:total_calamity_assistance_capsr] += 1
            elsif area["name"] == "NORTH LUZON"
              d[:total_calamity_assistance_jvo_amount] += c["amount"].to_f.round(2)
              d[:total_calamity_assistance_jvo] += 1
            else
              d[:total_calamity_assistance_kcoop_amount] += c["amount"].to_f.round(2)
              d[:total_calamity_assistance_kcoop] += 1
            end
          elsif c["claim_type"] == "K-BENTE"
            d[:total_kbente_claims] += c["amount"].to_f.round(2)

            if area["name"] == "HEAD OFFICE"
              d[:total_kbente_associate_amount] += c["amount"].to_f.round(2)
              d[:total_kbente_associate] += 1
            elsif area["name"] == "VISAYAS"
              d[:total_kbente_capsr_amount] += c["amount"].to_f.round(2)
              d[:total_kbente_capsr] += 1
            elsif area["name"] == "NORTH LUZON"
              d[:total_kbente_jvo_amount] += c["amount"].to_f.round(2)
              d[:total_kbente_jvo] += 1
            else
              d[:total_kbente_kcoop_amount] += c["amount"].to_f.round(2)
              d[:total_kbente_kcoop] += 1
            end
          elsif c["claim_type"] == "K-KALINGA"
            d[:total_kkalinga_claims] += c["amount"].to_f.round(2)
          
            if area["name"] == "HEAD OFFICE"
              d[:total_kkalinga_associate_amount] += c["amount"].to_f.round(2)
              d[:total_kkalinga_associate] += 1
            elsif area["name"] == "VISAYAS"
              d[:total_kkalinga_capsr_amount] += c["amount"].to_f.round(2)
              d[:total_kkalinga_capsr] += 1
            elsif area["name"] == "NORTH LUZON"
              d[:total_kkalinga_jvo_amount] += c["amount"].to_f.round(2)
              d[:total_kkalinga_jvo] += 1
            else
              d[:total_kkalinga_kcoop_amount] += c["amount"].to_f.round(2)
              d[:total_kkalinga_kcoop] += 1
            end
          elsif c["claim_type"] == "KUYA JUN SCHOLARSHIP PROGRAM"
            d[:total_kjsp_claims] += c["amount"].to_f.round(2)
          
            if area["name"] == "HEAD OFFICE"
              d[:total_kjsp_associate_amount] += c["amount"].to_f.round(2)
              d[:total_kjsp_associate] += 1
            elsif area["name"] == "VISAYAS"
              d[:total_kjsp_capsr_amount] += c["amount"].to_f.round(2)
              d[:total_kjsp_capsr] += 1
            elsif area["name"] == "NORTH LUZON"
              d[:total_kjsp_jvo_amount] += c["amount"].to_f.round(2)
              d[:total_kjsp_jvo] += 1
            else
              d[:total_kjsp_kcoop_amount] += c["amount"].to_f.round(2)
              d[:total_kjsp_kcoop] += 1
            end
          end
        end
      end

      if mc.present?
        counts = mc.data["counts"]

        d[:member_counts_as_of] = mc.meta["as_of"]

        d[:active_members][:male]   = counts["active_members"]["male"]
        d[:active_members][:female] = counts["active_members"]["female"]
        d[:active_members][:others] = counts["active_members"]["others"]
        d[:active_members][:total]  = counts["active_members"]["total"]

        d[:inforce_members][:male]   = counts["active_members"]["male_infoce"]
        d[:inforce_members][:female] = counts["active_members"]["female_inforce"]
        d[:inforce_members][:others] = counts["active_members"]["others_inforce"]
        d[:inforce_members][:total]  = counts["active_members"]["inforce"]

        d[:lapsed_members][:male]   = counts["active_members"]["male_lapsed"]
        d[:lapsed_members][:female] = counts["active_members"]["female_lapsed"]
        d[:lapsed_members][:others] = counts["active_members"]["others_lapsed"]
        d[:lapsed_members][:total]  = counts["active_members"]["lapsed"]

        d[:pending_members][:male]   = counts["active_members"]["male_pending"]
        d[:pending_members][:female] = counts["active_members"]["female_pending"]
        d[:pending_members][:others] = counts["active_members"]["others_pending"]
        d[:pending_members][:total]  = counts["active_members"]["pending"]

        d[:dormant_members][:male]   = counts["active_members"]["male_dormant"]
        d[:dormant_members][:female] = counts["active_members"]["female_dormant"]
        d[:dormant_members][:others] = counts["active_members"]["others_dormant"]
        d[:dormant_members][:total]  = counts["active_members"]["dormant"]

        d[:resigned_active_members][:male]   = counts["active_members"]["male_resigned"]
        d[:resigned_active_members][:female] = counts["active_members"]["female_resigned"]
        d[:resigned_active_members][:others] = counts["active_members"]["others_resigned"]
        d[:resigned_active_members][:total]  = counts["active_members"]["resigned"]
      end

      {
        id: branch.id,
        name: branch.name,
        cluster: {
          id: branch.cluster.id,
          name: branch.cluster.name
        },
        area: {
          id: branch.cluster.area.id,
          name: branch.cluster.area.name
        },
        data: d
      }
    end
  end
end
