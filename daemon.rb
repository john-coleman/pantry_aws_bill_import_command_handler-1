#!/usr/bin/env ruby
require 'rubygems'
require 'wonga/daemon'
require_relative 'pantry_import_aws_bill_command/pantry_import_aws_bill_command'
require 'rufus-scheduler'

config_name = File.join(File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__), "config", "daemon.yml")
Wonga::Daemon.load_config(File.expand_path(config_name))
Daemons.run_proc(config['daemon']['app_name'], config.daemon_config) {
  command = Wonga::Daemon::PantryImportAwsBillCommand.new(Wonga::Daemon.publisher,
                                                          AWS::S3.new.buckets[Wonga::Daemon.config['aws']['billing_bucket']],
                                                          Wonga::Daemon.logger)
  command.parse(true)

  Rufus::Scheduler.new.in  Wonga::Daemon.config['daemon']['job_interval']) do
    command.parse
  end
}
