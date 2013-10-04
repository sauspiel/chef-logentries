package "python-simplejson"

codename = node.lsb.codename

# logentries doesn't have a repository for raring, so we're using quantal as fallback
if node.platform == 'ubuntu' && node.lsb.codename == 'raring'
  codename = 'quantal'
end

apt_repository "logentries" do
  uri "http://rep.logentries.com"
  distribution codename
  components ["main"]
  key "http://rep.logentries.com/RPM-GPG-KEY-logentries"
  action :add
end

dpkg_autostart "logentries" do
  allow false
end

directory "/etc/le"

template "/etc/le/config" do
  not_if { File.exists?("/etc/le/config") }
  variables :key => node[:logentries][:user_key]
end

execute "install_logentries_daemon" do
  command "echo Y | apt-get install --yes logentries-daemon --force-yes"
  not_if "dpkg -l | grep -i logentries-daemon"
end

%w(logentries-daemon logentries).each do |pkg|
  package pkg do
    action :upgrade
  end
end

execute "register agent" do
  command "le register"
  not_if "grep agent-key /etc/le/config"
end

service "logentries" do
  action [:enable]
end

if node[:logentries][:logs]
  node[:logentries][:logs].each do |name, path|
    execute "follow file #{name} at #{path}" do
      command "le follow #{path} --name \"#{name}\""
      not_if "le followed #{path}"
      ignore_failure true
      notifies :restart, resources(:service => "logentries")
    end
  end
end
