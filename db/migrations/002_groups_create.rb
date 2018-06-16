# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      primary_key :id
      foreign_key :leader_id, table: :accounts
      
      String :title_secure, null: false
      String :description_secure
      
      Float :round_interval, null: false
      Integer :round_fee, null: false
      Float :bidding_duration, null: false
      Integer :bidding_upset_price, null: false
      
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
