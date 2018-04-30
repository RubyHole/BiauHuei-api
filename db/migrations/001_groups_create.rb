# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:groups) do
      primary_key :id
      
      String :title_secure, null: false
      String :description_secure
      
      Integer :total_members, null: false
      Float :round_period, null: false
      Integer :round_fee, null: false
      Integer :upset_price, null: false
      
      Float :rounds_started_after, null: false
      Float :bidding_ended_after, null: false
      
      DateTime :rounds_start_date_time
      Integer :current_round_id
    end
  end
end
