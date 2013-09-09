#!/usr/bin/env ruby
require 'rubygems'
require_relative 'pantry_import_aws_bill_command/pantry_import_aws_bill_command'

config_name = File.join(File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__), "config", "daemon.yml")
Wonga::Daemon.load_config(File.expand_path(config_name))

config = Wonga::Daemon.config
api_client = Wonga::Daemon::PantryApiClient.new(config['pantry']['url'], config['pantry']['api_key'], Wonga::Daemon.logger, config['pantry']['timeout'])
Wonga::Daemon.run(Wonga::Daemon::EC2BootstrappedEventHandler.new(api_client, Wonga::Daemon.logger))

