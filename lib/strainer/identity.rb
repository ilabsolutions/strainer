# frozen_string_literal: true

module Strainer
  # Gem identity information.
  module Identity
    def self.name
      'strainer'
    end

    def self.label
      'Strainer'
    end

    def self.version
      '0.1.0'
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
