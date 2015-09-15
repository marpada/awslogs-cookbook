require 'serverspec'

set :backend, :exec

describe process("aws") do
  its(:args) { should match /logs push/ }
end

describe service("awslogs") do
  it { should be_running.under('upstart')}
end

describe file("/var/awslogs/etc/awslogs.conf") do
  it { should exist }
  it { should be_file }
  it { should be_owned_by 'root' }
  its(:content) { should match /\[ test.log \]/ }
  its(:content) { should match /file = \/var\/log\/test.log/ }
  its(:content) { should match /log_stream_name = {instance_id}/ }
  its(:content) { should match /datetime_format = %Y-%m-%d %H:%M:%S/ }
end

describe file("/var/log/awslogs.log") do
  it { should exist }
  it { should be_owned_by 'root' }
end
