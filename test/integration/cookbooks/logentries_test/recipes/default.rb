#
# Cookbook Name:: logentries_test
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

node.override['logentries']['logs'] = { 
  'syslog' => '/var/log/syslog',
  'user' => '/var/log/user.log'
  }

include_recipe "logentries"
