# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:bids) do
      primary_key :id
      foreign_key :group_id, table: :groups
      foreign_key :account_id, table: :accounts
      
      String :bid_price_secure, null: false
      String :submit_type, null: false
      #String :previous_hash
      
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
