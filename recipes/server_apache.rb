node['apache']['default_modules'] << 'expires' if platform?("redhat", "centos", "scientific", "fedora", "amazon")

include_recipe "apache2"
include_recipe "apache2::mod_rewrite"

apache_site "000-default" do
  enable false
end

if node['munin']['public_domain']
  public_domain = node['munin']['public_domain']
else
  if node['public_domain']
    case node.chef_environment
    when "production"
      public_domain = node['public_domain']
    else
      public_domain = "#{node.chef_environment}.#{node['public_domain']}"
    end
  else
    public_domain = node['domain']
  end
  chef_env = node.chef_environment == '_default' ? 'default' : node.chef_environment
  public_domain = "munin.#{chef_env}.#{public_domain}"
end

template "#{node['apache']['dir']}/sites-available/munin.conf" do
  source "apache2.conf.erb"
  mode 0644
  variables(:public_domain => public_domain, :docroot => node['munin']['docroot'], :listen_port => node['munin']['web_server_port'])
  if ::File.symlink?("#{node['apache']['dir']}/sites-enabled/munin.conf")
    notifies :reload, "service[apache2]"
  end
end

apache_site "munin.conf"
