#
# Cookbook Name:: nagios
# Recipe:: default
#
# Copyright 2012, Cogini
#
# All rights reserved - Do Not Redistribute
#

distro_recipe = value_for_platform(
    %w{redhat centos} => {
        'default' => 'nagios::centos'
    },
    # Ubuntu
    'default' => 'nagios::ubuntu'
)

include_recipe distro_recipe


nrpe_service = value_for_platform(
    %w{redhat centos} => {
        'default' => 'nrpe'
    },
    # Ubuntu
    'default' => 'nagios-nrpe-server'
)

service nrpe_service do
    action [:start, :enable]
    supports :restart => true, :reload => true
end


template '/etc/nagios/nrpe.cfg' do
    source 'nrpe.cfg.erb'
    notifies :restart, "service[#{nrpe_service}]"
end


unless node[:platform] = 'ubuntu' && node[:platform_version].to_f <= 8.04
    include_recipe 'logwarn'
end
