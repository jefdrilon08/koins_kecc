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
        .where("meta->>'data_store_type' IN (?) AND meta->>'branch_id' IN (?) AND DATE(meta->>'as_of') <= ?", %w[INSURANCE_MEMBER_COUNTS], @branches.ids, @as_of)
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
      d = {
        as_of: "",
        member_counts_as_of: "",
        active_members:           { male: 0, female: 0, others: 0, total: 0 },
        inforce_members:          { male: 0, female: 0, others: 0, total: 0 },
        lapsed_members:           { male: 0, female: 0, others: 0, total: 0 },
        pending_members:          { male: 0, female: 0, others: 0, total: 0 },
        dormant_members:          { male: 0, female: 0, others: 0, total: 0 },
        resigned_active_members:  { male: 0, female: 0, others: 0, total: 0 },
      }

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
