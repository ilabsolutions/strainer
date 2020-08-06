# frozen_string_literal: true

require 'spec_helper'
require 'action_controller'

module ActionController
  class Parameters
    def initialize(*); end
  end
end

module Strainer
  module Behaviors
    RSpec.describe ParametersAsHash, behavior: true do
      context '#is_a?' do
        let(:params) { ActionController::Parameters.new(records: { datetime: { date: '10/10/10', time: '10:10' } }) }

        context 'when Hash' do
          it { expect(params.is_a?(Hash)).to be true }
        end

        context 'when Array' do
          it { expect(params.is_a?(Array)).to be false }
        end

        context 'for case comparison' do
          let(:case_comparison) do
            case params
            when Hash
              true
            else
              false
            end
          end

          it { expect(case_comparison).to be true }
          it { expect(Hash === params).to be true } # rubocop:disable Style/CaseEquality since this tests a monkeypatch
        end
      end
    end
  end
end
