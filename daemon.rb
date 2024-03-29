#!/usr/bin/env ruby
require 'daemons'
require 'wonga/daemon'
require_relative 'pantry_import_aws_bill_command/pantry_import_aws_bill_command'

config_name = File.join(File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__), 'config', 'daemon.yml')
Wonga::Daemon.load_config(File.expand_path(config_name))
Daemons.run_proc(Wonga::Daemon.config['daemon']['app_name'], Wonga::Daemon.config.daemon_config) do
  command = Wonga::Daemon::PantryImportAwsBillCommand.new(Wonga::Daemon.publisher,
                                                          Aws::S3::Bucket.new(Wonga::Daemon.config['aws']['billing_bucket']),
                                                          Wonga::Daemon.logger)
  command.parse(true)

  loop do
    sleep Wonga::Daemon.config['daemon']['job_interval'].to_i
    command.parse
  end
end
