class AppValidator
  def initialize
    @errors = {
      messages: [],
      full_messages: []
    }
  end

  def not_yet_implemented!
    @errors[:messages] << {
      key: "system",
      message: "not yet implemented"
    }
  end
end
