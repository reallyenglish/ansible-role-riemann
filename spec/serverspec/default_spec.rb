require 'spec_helper'
require 'serverspec'

package = 'riemann'
service = 'riemann'
config  = '/etc/riemann/riemann.config'
user    = 'riemann'
group   = 'riemann'
ports   = [ 5555, 5556 ]
log_dir = '/var/log/riemann'

case os[:family]
when 'freebsd'
  config = '/usr/local/etc/riemann/riemann.config'
end

describe package(package) do
  it { should be_installed }
end 

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

if os[:family] == 'freebsd'
  describe file('/etc/rc.conf.d/riemann') do
    it { should be_file }
    its(:content) { should match Regexp.escape('riemann_config="/usr/local/etc/riemann/riemann.config"') }
    its(:content) { should match /riemann_max_mem="768m"/ }
  end
end

describe file(config) do
  it { should be_file }
  its(:content) { should match /; -\*- mode: clojure; -\*-/ }
  its(:content) { should match /; vim: filetype=clojure/ }
  its(:content) { should match Regexp.escape('; Listen on the local interface over TCP (5555), UDP (5555), and websockets') }
end
