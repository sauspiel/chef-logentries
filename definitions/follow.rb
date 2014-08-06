define :logentries_follow do
  name = params[:name]
  path = params[:path]
  unless node[:logentries][:ignore_environments].include?(node.chef_environment)
    execute "follow file #{name} #{path}" do
      command "le follow #{path} --name \"#{name}\""
      not_if "le followed #{path}"
      ignore_failure true
      notifies :restart, resources(service: 'logentries')
    end
  end
end
