require 'spec_helper'
describe 'rsnapshot' do
  # Packages
  it { should contain_package('rsnapshot').with_ensure('present') }
  
  # Users
  it {
    should contain_user('rsnapshot').only_with(
      'ensure' => 'present',
      'home'   => '/home/rsnapshot',
      'managehome' => true
    )
  } 
end
