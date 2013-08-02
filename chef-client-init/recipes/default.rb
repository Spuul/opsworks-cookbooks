#
# Cookbook Name:: chef-client-init
# Recipe:: default
#
# Copyright 2013, Daniel Muller (spuul.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "chef-client::config"

Chef::Log.info("chef-client-init :: validation.pem is empty") if node["chef_client_init"]["validation"].nil?
Chef::Log.info("chef-client-init :: no first boot data") if node["chef_client_init"]["first_boot"].nil?

return if node["chef_client_init"]["validation"].nil? || node["chef_client_init"]["first_boot"].nil?

file "#{node["chef_client"]["conf_dir"]}/validation.pem" do
    owner "root"
    group "root"
    mode "0400"
    content node["chef_client_init"]["validation"]
    action :create
end
file "#{node["chef_client"]["conf_dir"]}/first_boot.json" do
    owner "root"
    group "root"
    mode "0400"
    content node["chef_client_init"]["first_boot"]
    action :create
end

execute "chef-init" do
    Chef::Log.info("chef-client-init :: Running #{node["chef_client"]["bin"]}")
    command "#{node["chef_client"]["bin"]} -j #{node["chef_client"]["conf_dir"]}/first_boot.json -E #{node["chef_client_init"]["environment"]}"
    action :run
    only_if File.exists?("#{node["chef_client"]["conf_dir"]}/client.rb")
end

include_recipe "chef-client::default"
