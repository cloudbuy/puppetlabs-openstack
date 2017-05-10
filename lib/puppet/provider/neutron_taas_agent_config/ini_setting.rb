# hack to support running on the server and the client
begin
  require File.join(File.dirname(__FILE__), '..','..','..', '..', '..',
                    'neutron/lib/puppet/provider/neutron')
rescue LoadError
  require File.join(File.dirname(__FILE__), '..','..','..',
                    'puppet/provider/neutron')
end

Puppet::Type.type(:neutron_taas_agent_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/neutron/taas.ini'
  end

  # added for backwards compatibility with older versions of inifile
  def file_path
    self.class.file_path
  end

end

