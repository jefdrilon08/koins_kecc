class AdjustmentRecord < ApplicationRecord
  STATUSES  = [
    "pending", 
    "approved",
    "processing"
  ]

  ADJUSTMENT_TYPES  = [
    "reamortization",
    "subsidiary",
    "batch_moratorium"
  ]

  validates :meta, presence: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :adjustment_type, presence: true, inclusion: { in: ADJUSTMENT_TYPES }

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }

  scope :reamortization, -> { where(adjustment_type: "reamortization") }
  scope :subsidiary, -> { where(adjustment_type: "subsidiary") }
  scope :batch_moratorium, -> { where(adjustment_type: "batch_moratorium") }

  before_validation :load_defaults

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end

  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end

  def selectable_subsidiary_members
    temp_meta             = self.meta.with_indifferent_access
    subsidiary_member_ids = self.subsidiary_members.pluck(:id)

    Member.active.where(branch_id: temp_meta[:branch][:id]).order("last_name ASC").map{ |o|
      {
        id: o.id,
        first_name: o.first_name,
        middle_name: o.middle_name,
        last_name: o.last_name,
        branch: {
          id: o.branch.id,
          name: o.branch.name
        },
        center: {
          id: o.center.id,
          name: o.center.name
        }
      }
    }
  end

  def non_subsidiary_members
    temp_meta             = self.meta.with_indifferent_access
    subsidiary_member_ids = self.subsidiary_members.pluck(:id)

    Member.active.where(branch_id: temp_meta[:branch][:id]).where.not(id: subsidiary_member_ids).order("last_name ASC").map{ |o|
      {
        id: o.id,
        first_name: o.first_name,
        middle_name: o.middle_name,
        last_name: o.last_name,
        branch: {
          id: o.branch.id,
          name: o.branch.name
        },
        center: {
          id: o.center.id,
          name: o.center.name
        }
      }
    }
  end

  def subsidiary_members
    temp_data = self.data.with_indifferent_access

    ids = []

    temp_data[:records].each do |o|
      ids << o[:member][:id]
    end

    Member.where(id: ids).order("last_name ASC").map{ |o|
      {
        id: o.id,
        first_name: o.first_name,
        middle_name: o.middle_name,
        last_name: o.last_name,
        branch: {
          id: o.branch.id,
          name: o.branch.name
        },
        center: {
          id: o.center.id,
          name: o.center.name
        }
      }
    }
  end
end
