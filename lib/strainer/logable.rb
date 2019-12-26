# frozen_string_literal: true

module Strainer
  module Logable
    def strainer_log(message, exception = nil, custom: {})
      Strainer::Railtie.config.logger.report(message: message, exception: exception, custom: custom)
    end
  end
end
