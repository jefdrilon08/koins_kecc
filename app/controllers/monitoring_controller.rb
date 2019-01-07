class MonitoringController < ApplicationController
  before_action :load_defaults

  def accounting_entry_subsidiary_balancing
    @branches = @branches.map{ |o| { id: o.id, name: o.name } }
  end
end
