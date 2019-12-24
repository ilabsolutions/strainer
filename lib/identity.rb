# frozen_string_literal: true

module .
  # Gem identity information.
  module Identity
    def self.name
      "."
    end

    def self.label
      "."
    end

    def self.version
      "0.1.0"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
