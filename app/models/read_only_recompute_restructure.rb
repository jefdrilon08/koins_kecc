class ReadOnlyRecomputeRestructure < RecomputeRestructure
  establish_connection(ENV['FOLLOWER_READ_ONLY_DATABASE_URL'])
end
