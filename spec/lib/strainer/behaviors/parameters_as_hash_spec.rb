# frozen_string_literal: true

require 'spec_helper'

module MissingConfigurationMethods
  def ancestors; end
  def logger
    Strainer::FileLogger.new 'spec/fixtures/files/test.log'
  end
end

module ActionController
  class Parameters
    def initialize(*); end
  end
end

module Strainer
  module Behaviors
    RSpec.describe ParametersAsHash do
      before do
        Rails::Railtie::Configuration.include MissingConfigurationMethods        
        described_class.new.apply_patch!
      end

      context '#is_a?' do
        let(:params) { ActionController::Parameters.new(records: { datetime: { date: '10/10/10', time: '10:10'} }) }

        context 'when Hash' do
          it { expect(params.is_a?(Hash)).to be true }
        end

        context 'when ActionController::Parameters' do
          it { expect(params.is_a?(ActionController::Parameters)).to be true }
        end

        context 'when Array' do
          it { expect(params.is_a?(Array)).to be false }
        end
      end
    end
  end
end
