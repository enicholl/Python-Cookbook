
# Cookbook:: python
# Spec:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'python::default' do
  context 'When all attributes are default, on Ubuntu 18.04' do
    # for a complete list of available platforms and versions see:
    # https://github.com/chefspec/fauxhai/blob/master/PLATFORMS.md
    platform 'ubuntu', '18.04'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
    it 'should install python-dev' do
      expect(chef_run).to install_package 'python3-dev'
    end
    it 'should install python3-pip3' do
      expect(chef_run).to install_package 'python3-pip'
    end
    it 'should install packages' do
      expect(chef_run).to run_execute 'install /home/ubuntu/app/requirements.txt'
    end
    # it 'should have installed requirements' do
    #   expect(chef_run).to install_python_package 'beautifulsoup4'
    # end
  # it { is_expected.to install_python_package('foo') }
    it 'should create Downloads directory' do
      expect(chef_run).to create_directory '/home/vagrant/Downloads'
    end
    it 'should create .csv file' do
      expect(chef_run).to create_file '/home/vagrant/Downloads/ItJobWatchTop30.csv'
    end




  end
end
