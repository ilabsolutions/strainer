# frozen_string_literal: true

require 'spec_helper'
require 'action_controller'

module Strainer
  module Behaviors
    RSpec.describe ParameterizeChanges, behavior: true do
      subject(:str) { 'Donald E. Knuth' }
      let(:dashed_str) { 'donald-e-knuth' }
      let(:plussed_str) { 'donald+e+knuth' }

      it('works with no args') { expect(str.parameterize).to eq(dashed_str) }
      it('works like rails 4') { expect(str.parameterize('+')).to eq(plussed_str) }
      it('works like rails 6') { expect(str.parameterize(separator: '+')).to eq(plussed_str) }
    end
  end
end
