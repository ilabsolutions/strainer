# frozen_string_literal: true

require 'spec_helper'
require 'active_record'

module Strainer
  module Behaviors
    RSpec.describe ActiveRecordBeforeCallbackChanges, behavior: true do
      before(:all) do
        ActiveRecord::Migration.verbose = false

        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

        ActiveRecord::Schema.define(version: 1) do
          create_table :fakes do |t|
            t.string :email, default: 'test@test.test'
          end
        end
      end

      after(:all) do
        ActiveRecord::Base.connection.close
      end

      let(:application_record) do
        Class.new(ActiveRecord::Base) do
          intercept_rails4_callbacks
          self.table_name = 'fakes'
        end
      end

      let(:klazz_with_false_returning_callback) do
        Class.new(application_record) do
          before_save -> { false }
        end
      end

      let(:klazz_with_throwing_callback) do
        Class.new(application_record) do
          before_save -> { throw(:abort) }
        end
      end

      let(:klazz_with_block_callback) do
        Class.new(application_record) do
          before_save { false }
        end
      end

      let(:klazz_with_function_callback) do
        Class.new(application_record) do
          before_save :returning_false

          def returning_false
            false
          end
        end
      end

      let(:klazz_with_false_before_destroy) do
        Class.new(application_record) do
          before_destroy :returning_false

          def returning_false
            false
          end
        end
      end

      context 'for before_save that returns false' do
        %I[
          klazz_with_false_returning_callback
          klazz_with_throwing_callback
          klazz_with_block_callback
          klazz_with_function_callback
        ].each do |klazz|
          it("#{klazz} fails with save") { expect(send(klazz).new.save).to be(false) }
          it("#{klazz} raises with save!") do
            expect { send(klazz).new.save! }.to raise_exception(ActiveRecord::RecordNotSaved)
          end
        end
      end

      context 'for before_destroy that returns false' do
        let(:model) { klazz_with_false_before_destroy.create }
        it('raises on destroy!') { expect { model.destroy! }.to raise_exception(ActiveRecord::RecordNotDestroyed) }
        it('fails to destroy') { expect(model.destroy).to be(false) }
      end
    end
  end
end
