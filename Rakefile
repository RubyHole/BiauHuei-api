# frozen_string_literal: true

require 'rake/testtask'

task default: [:spec]

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby specs/api_spec.rb'
end

desc 'Run all the tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'specs/*_spec.rb'
  t.warning = false
end

desc 'Runs rubocop on tested code'
task style: [:spec] do
  sh 'rubocop **/*.rb'
end

task :print_env do
  puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
end

desc 'Run  application  console  (pry)'
task :console => :print_env do
  sh 'pry -r ./specs/test_load_all'
end

desc 'Run application in development mode and port'
task :run_dev do
  puts "rackup at port #{ENV['RACK_PORT'] || '3000'}"
  sh "rerun -c 'rackup -p #{ENV['RACK_PORT'] || '3000'}'"
end

namespace :db do
  
  task :setup do
    require 'sequel'
    Sequel.extension :migration
    
    require_relative 'lib/init' # load libraries
    require_relative 'config/init' # load config info
  
    app = BiauHuei::Api
  end
  
  task :load_models do
    require_relative 'models/init'
    #require_relative 'services/init'
  end
  
  desc 'Run migrations'
  task :migrate => [:setup, :print_env] do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(app.DB, 'db/migrations')
  end
  
  desc'Delete dev or test database file'
  task :drop => :print_env do
    if app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end
    
    FileUtils.rm(app.config.DB_FILENAME)
    puts "Deleted #{app.config.DB_FILENAME}"
  end
  
  desc 'Delete and migrate again'
  task reset: [:drop, :migrate]
  
  task :reset_seeds => [:setup, :load_models] do
    app.DB[:schema_seeds].delete if app.DB.tables.include?(:schema_seeds)
    BiauHuei::Group.dataset.destroy
    BiauHuei::Account.dataset.destroy
  end

  desc 'Seeds the development database'
  task :seed => [:setup, :print_env, :load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(app.DB, 'db/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: [:reset_seeds, :seed]
end

namespace :crypto do
  desc 'Create sample cryptographic key for database'
  task :db_key do
    require_relative 'lib/secure_db'
    puts "DB_KEY: #{SecureDB.generate_key}"
  end
  
  desc 'Create sample cryptographic key for tokens and messaging'
  task :msg_key do
    require_relative 'lib/auth_token'
    puts "MSG_KEY: #{AuthToken.generate_key}"
  end
end
