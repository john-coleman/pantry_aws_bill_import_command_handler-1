#!/usr/bin/env ruby
require 'rubygems'
require 'wonga/daemon'
require_relative 'pantry_import_aws_bill_command/pantry_import_aws_bill_command'

config_name = File.join(File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__), "config", "daemon.yml")
Wonga::Daemon.load_config(File.expand_path(config_name))
# require 'pry'
# binding.pry
Wonga::Daemon.run(Wonga::Daemon::PantryImportAwsBillCommand.new(
  Wonga::Daemon.publisher,
  AWS::S3.new.buckets[Wonga::Daemon.config['aws']['billing_bucket']],
  Wonga::Daemon.pantry_api_client, Wonga::Daemon.logger)
)
