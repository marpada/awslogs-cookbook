require 'serverspec'

set :backend, :exec

describe process("aws") do
  its(:args) { should match /logs push/ }
end

describe service("awslogs") do
  it { should be_enabled}
  it { should be_running}
end

describe file("/var/awslogs/etc/awslogs.conf") do
  it { should exist }
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe file("/var/log/awslogs.log") do
  it { should exist }
  it { should be_owned_by 'root' }
end
