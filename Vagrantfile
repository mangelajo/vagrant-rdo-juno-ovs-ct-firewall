require 'vagrant-reload'

Vagrant.configure('2') do |config|

  config.vm.hostname  = 'rdojuno'



  config.vm.provision :shell, :inline=> <<-EOF
        set -e
        set -x
        # configure our patched RDO packages and a RDO mirror for juno
        curl http://fileshare.ajo.es/rdo-juno-neutron-ovsct/rdo_juno_ovsct.repo >/etc/yum.repos.d/centos-rdo.repo
        # sudo yum install -y https://rdo.fedorapeople.org/rdo-release.rpm
        sudo yum install -y deltarpm epel-release
        sudo yum update -y
        sudo yum install openstack-packstack -y
  EOF

  # restart to make sure we're using the latest kernel
  config.vm.provision :reload

  config.vm.provision :shell, :inline => <<-EOF

        /vagrant/ovs-install.sh

        # workaround for a issue in packstack with iptables happening randomly
        sudo yum install -y iptables iptables-services

        sudo packstack --allinone --default-password=123456 \
                        --provision-tempest=y \
                        --os-swift-install=n \
                        --nagios-install=n \
                        --os-heat-install=n \
                        --os-ceilometer-install=n \
                        --use-epel=y

        sudo openstack-config --set \
            /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini \
           securitygroup firewall_driver neutron.agent.linux.openvswitch_firewall.OVSFirewallDriver
        service neutron-openvswitch-agent restart
        # neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

        # make horizon accessible for any IP address / hostname on the host
        sed -i 's/<\/VirtualHost>/ServerAlias \*\n  <\/VirtualHost>/g' \
                /etc/httpd/conf.d/15-horizon_vhost.conf
        service httpd restart
      exit 0
  EOF


  config.vm.provision :shell, :privileged=>false,
                      :inline=> <<-EOF
        # personalize git, etc, anything you use for development

        if [ -f /vagrant/personal_settings.sh ]; then
            /vagrant/personal_settings.sh
        else
            echo personal_settings.sh is not available
            echo you can use personal_settings.sh.example as a template if you
            echo want.
        fi
  EOF
  #specific provider sections

  config.vm.box       = 'chef/centos-7.0'
  config.vm.provider :virtualbox do |v|
    v.memory = 3024
    v.cpus = 4
  end

  config.vm.provider :openstack do |os, override|
    os.server_name        = 'rdojuno'
    os.openstack_auth_url = "#{ENV['OS_AUTH_URL']}/tokens"
    os.username           = "#{ENV['OS_USERNAME']}"
    os.password           = "#{ENV['OS_PASSWORD']}"
    os.tenant_name        = "#{ENV['OS_TENANT_NAME']}"
    os.flavor             = ['oslab.4cpu.20hd.8gb', 'm1.large']
    os.image              = ['centos7', 'centos-7-cloud']
    os.floating_ip_pool   = ['external', 'external-compute01']
    os.user_data          = <<-EOF
#!/bin/bash
sed -i 's/Defaults    requiretty/Defaults    !requiretty/g' /etc/sudoers
    EOF
    override.ssh.username = 'centos'
  end

  config.vm.provider :parallels do |v, override|
    override.vm.box = "parallels/centos-7.0"
    v.memory = 3024
    v.cpus = 4
    override.vm.network "private_network", ip: "192.168.33.11",
                                           dns: "8.8.8.8"

  end


end
