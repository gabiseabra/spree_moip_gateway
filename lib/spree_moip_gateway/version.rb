module SpreeMoipGateway
  module_function

  # Returns the version of the currently loaded SpreeMoipGateway as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 3
    TINY  = 1
    # PRE   = 'alpha'.freeze

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end
end
