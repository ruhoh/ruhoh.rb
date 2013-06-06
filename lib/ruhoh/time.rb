class Time
  class << self
    attr_accessor :default_format
    default_format = "%Y-%m-%d %H:%M:%S %z"
  end

  def to_s
    strftime Time.default_format
  end
end
