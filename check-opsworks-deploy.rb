#!/usr/bin/env ruby
#
# Check Opsworks deploy status
# ===
#
# This script check opsworks deploy status.
#
# requirements
# * aws cli
#   http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html
#   set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables before using this script.
#   The best practice is using IAM Role.
#
# Copyright 2014 Jun Ichikawa <jun1ka0@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE for details.

require 'sensu-plugin/check/cli'
require 'json'

class CheckOpsworksDeploy < Sensu::Plugin::Check::CLI

  check_name 'check_opsworks_deploy'

  option :warn_at_running,
    :short => '-w WARN AT RUNNING',
    :long => '--warn-at-running WARNING',
    :description => "Raise WARN when deploy is running",
    :boolean => true,
    :default => false

  option :aws_region,
    :short => '-r AWS_REGION',
    :long => '--aws-region REGION',
    :description => "AWS Region",
    :required => true,
    :default => 'us-east-1'

  option :appid,
    :short => '-a APPID',
    :long => '--app_id application ID',
    :description => "Application ID for check",
    :default => ''

  option :stackid,
    :short => '-s STACKID',
    :long => '--stack_id stack ID',
    :description => "Stack ID for check",
    :default => ''

  def run
    if !config[:appid].empty?
      target_cmd = "--app-id  #{config[:appid]}"
    elsif !config[:stackid].empty?
      target_cmd = "--stack-id #{config[:stackid]}"
    else
      unknown "appid or stackid is required."
    end

    begin
      result = `aws opsworks --region #{config[:aws_region]} describe-deployments #{target_cmd}`
      if result.empty?
        critical "command failed with no result"
      end

      json_hash = JSON.parser.new(result).parse['Deployments']
      if json_hash.size == 0
        unknown "deploy data not found"
      end

      json_hash.sort! { |a, b| b['CompletedAt'] <=> a['CompletedAt'] }
      last_deploy = json_hash[0]
      output "status #{last_deploy['Status']}"
      output "CompletedAt #{last_deploy['CompletedAt']}"
      output "Instances #{last_deploy['InstanceIds'].size}"
      if last_deploy['Status'].downcase == 'successful'
        ok "Deploy done"
      elsif last_deploy['Status'].downcase == 'running'
        if config[:warn_at_running]
          warning "Deploy is running"
        else
          ok "Deploy is running"
        end
      else
        critical "Deploy faild"
      end
    rescue => ex
      critical "command failed. #{ex.message}"
    end
  end

end
