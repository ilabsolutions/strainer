# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    class AbstractMysqlAdapter < Strainer::RuntimeBehavior
      # This module replace old user stamp columns `created_by` and `updated_by` into `created_by_id` and `updated_by_id`
      # It logs usages so that the code can be later corrected.
      #
      # @example
      # Model.select('created_by, updated_by') => `SELECT created_by_id, updated_by_id FROM model`
      # Model.find_by_sql('SELECT created_by, updated_by FROM model') => `SELECT created_by_id, updated_by_id FROM model`
      # ActiveRecord::Base.connection.select_all('SELECT created_by, updated_by FROM model') => `SELECT created_by_id, updated_by_id FROM model`
      # ActiveRecord::Base.connection.select_all('SELECT * FROM model WHERE created_by IS NULL') => `SELECT * FROM model WHERE created_by_id IS NULL`
      module ReplaceUserStamp
        include Strainer::Logable

        STATEMENTS_REGEX = %r{(?i)(SELECT|INSERT|UPDATE|DELETE)\b}.freeze
        USER_STAMP_REGEX = %r{(?i)(created_by|updated_by)\b}.freeze

        # Executes the SQL statement in the context of this connection.
        def execute(sql, name = nil)
          if sql.match?(STATEMENTS_REGEX) && sql.match?(USER_STAMP_REGEX)
            strainer_log('SQL_WITH_USER_STAMP', custom: { name: name, sql: sql })
            sql = sql.dup.gsub(USER_STAMP_REGEX) { |column| "#{column}_id" }
          end

          super
        end
      end

      def apply_patch!
        ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter.prepend(ReplaceUserStamp)
      end
    end
  end
end
