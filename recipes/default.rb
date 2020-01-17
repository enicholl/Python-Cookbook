#
# Cookbook:: python
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.
# include_recipe 'apt'
# include_recipe 'python'
#include_recipe 'python::pip'
apt_update 'update' do
  action :update
end
package 'python3-dev' do
  action :install
end
package 'python3-pip' do
  action :install
end
# directory '/home/ubuntu/app' do
#   action :create
# end
remote_directory '/home/ubuntu/app' do
  source 'app'
  action :create
end
execute 'install /home/ubuntu/app/requirements.txt' do
  command 'pip3 install -r home/ubuntu/app/requirements.txt'
  action :run
end
directory '/home/vagrant/Downloads' do
  action :create
end
file '/home/vagrant/Downloads/ItJobWatchTop30.csv' do
  action :create
end
