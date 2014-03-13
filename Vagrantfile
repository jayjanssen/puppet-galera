# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos-6_5-64_percona"
  config.vm.network :private_network, ip: '192.168.70.2'
  config.ssh.username = "root"
  
  # install librarian-puppet and run it to install puppet common modules.
  # This has to be done before puppet provisioning so that modules are available
  # when puppet tries to parse its manifests
  # config.vm.provision :shell, :path => "provision/librarian-puppet.sh"

  config.vm.provision :puppet do |puppet|
    
    puppet.manifest_file = "combined.pp"    
    puppet.module_path = [ 'modules-contrib', 'modules' ]
    
    puppet.options = "--verbose"
  end
  
  config.vm.provider :virtualbox do |vb, override|
    vb.customize ["modifyvm", :id, "--ioapic", "on" ]
  end
end
