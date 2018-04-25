# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:members) do
      primary_key :id
      foreign_key :group_id, table: :groups
      #foreign_key :user_id, table: :users
        
      TrueClass :is_leader, null: false
    end
  end
end
