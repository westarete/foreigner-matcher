unless ENV['TRAVIS']
  require 'bundler'
  Bundler::GemHelper.install_tasks
end

namespace :db do
  namespace :test do
    desc "Reset the test database"
    task :reset do
      require 'yaml'
      require 'active_record'
      require 'rails'
      require 'rails/railtie'

      def print_table_creation(new_table)
        print "\tCreating #{new_table}..."
        yield
        print "done\n"
      end

      def print_foreign_key_creation(fk_table)
        print "\tCreating key on #{fk_table}..."
        yield
        print "done\n"
      end

      puts "Establishing connection to test db..."
      db_config_yml = File.dirname(__FILE__)
      db_config_yml << (ENV['TRAVIS'] ? '/ci' : '/spec')
      db_config_yml << '/config/database.yml'
      db_configs = YAML::load(File.open(db_config_yml))
      db_adapter = ENV['DB']
      db_config  = db_configs[db_adapter]
      ActiveRecord::Base.configurations = db_configs
      ActiveRecord::Base.establish_connection(db_config)
      conn = ActiveRecord::Base.connection
      puts "Connected to #{db_config['database']} via a #{db_config['adapter']} connector"

      puts "\nDropping test tables, if they exist"
      %w( default_options user_logins comments searches special_user_records table_without_foreign_keys user_types users ).each do |test_table|
        print "\tDropping #{test_table}..."
        conn.execute("drop table if exists #{test_table}")
        print "done\n"
      end

      puts "\nCreating test tables"
      print_table_creation('users') do
        conn.create_table(:users) do |t|
          t.string :username
          t.string :email, :default => 'nobody@localhost'
        end
      end
      print_table_creation('special_user_records') do
        conn.create_table(:special_user_records) do |t|
          t.integer :special_user_id
          t.integer :special_user_type_id
        end
      end
      [ :default_options, :user_logins, :user_types, :comments, :searches, :table_without_foreign_keys ].each do |user_table|
        print_table_creation(user_table) do
          conn.create_table(user_table) do |t|
            t.integer :user_id
          end
        end
      end

      # Include ActiveRecordVersionHelpers
      require "#{File.dirname(__FILE__)}/spec/support/active_record_version_helpers.rb"
      include ActiveRecordVersionHelpers

      require 'foreigner'
      if active_record_version > 3.0
        Foreigner::Railtie.instance.run_initializers
      else
        foreigner_railtie = Foreigner::Railtie.new
        foreigner_railtie.run_initializers(foreigner_railtie)
      end

      puts "\nCreating foreign keys"
      print_foreign_key_creation('default_options') do
        conn.add_foreign_key(:default_options, :users)
      end
      print_foreign_key_creation('user_logins') do
        conn.add_foreign_key(:user_logins, :users, :dependent => :nullify)
      end
      print_foreign_key_creation('user_types') do
        conn.add_foreign_key(:user_types, :users, :dependent => :restrict)
      end
      print_foreign_key_creation('comments') do
        conn.add_foreign_key(:comments, :users, :dependent => :delete)
      end
      print_foreign_key_creation('searches') do
        conn.add_foreign_key(:searches, :users, :name => "user_search_special_fk", :dependent => :delete)
      end
      print_foreign_key_creation('special_user_records') do
        conn.add_foreign_key(:special_user_records, :users, :column => "special_user_id", :dependent => :delete)
        conn.add_foreign_key(:special_user_records, :user_types, :column => "special_user_type_id", :name => "special_user_type_fk")
      end
    end
  end
end
