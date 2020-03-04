class TurkeyController < ApplicationController
  before_action :authenticate_user!

  def index
    @operations = TurkeyOperation.all
  end
end

class TurkeyOperation
  def self.all
    paths = Dir.glob(File.join(Rails.root, "app", "operations", "**", "*.rb"))
    paths.map do |path|
      klass = Pathname
        .new(path)
        .relative_path_from(Pathname.new(File.join(Rails.root, "app", "operations")))
        .to_s[0..-4]
        .camelcase
        .constantize
      new(klass)
    end
  end

  attr_reader :klass

  def initialize(klass)
    @klass = klass
  end

  def name
    @klass.name
  end

  def initialize_params
    klass.instance_method(:initialize).parameters.map { |p| ":#{p[1]}" }
  end
end
