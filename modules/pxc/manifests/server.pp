
# Class: galera::server
#
# manages the installation of the mysql wsrep and galera.
# manages the package, service, wsrep.cnf
#
# Parameters:
#  [*config_hash*]         - hash of config parameters that need to be set.
#  [*enabled*]             - Defaults to true, boolean to set service ensure.
#  [*manage_service*]      - Boolean dictating if mysql::server should manage the service.
#  [*root_group]           - use specified group for root-owned files.
#  [*package_ensure*]      - Ensure state for package. Can be specified as version.
#  [*galera_package_name*] - The name of the galera package.
#  [*wsrep_package_name*]  - The name of the wsrep package.
#  [*libaio_package_name*] - The name of the libaio package.
#  [*libssl_package_name*] - The name of the libssl package.
#  [*wsrep_deb_name*]      - The name of wsrep .deb file.
#  [*galera_deb_name*]     - The name of galera .deb file.
#  [*wsrep_deb_name*]      - The URL to download the wsrep .deb file.
#  [*galera_deb_name*]     - The URL to download the galera .deb file.
#  [*galera_package_name*] - The name of the Galera package.
#  [*wsrep_package_name*]  - The name of the WSREP package.
#  [*cluster_name*]        - Logical cluster name. Should be the same for all nodes.
#  [*master_ip*]           - IP address of the group communication system handle.
#    The first node in the cluster should be left as the default (false) until the cluster is formed.
#    Additional nodes in the cluster should have an IP address set to a node in the cluster.
#  [*wsrep_sst_username*]  - Username used by the wsrep_sst_auth authentication string.
#    Used to secure the communication between cluster members.
#  [*wsrep_sst_password*]  - Password used by the wsrep_sst_auth authentication string.
#    Used to secure the communication between cluster members.
#  [*wsrep_sst_method*]    - WSREP state snapshot transfer method.
#    Defaults to 'mysqldump'.  Note: 'rsync' is the most widely tested.
#
# Requires:
#
# Sample Usage:
# class { 'mysql::server::galera':
#   config_hash => {
#     'root_password' => 'root_pass',
#   },
#    cluster_name       => 'galera_cluster',
#    master_ip          => false,
#    wsrep_sst_username => 'ChangeMe',
#    wsrep_sst_password => 'ChangeMe',
#    wsrep_sst_method   => 'rsync'
#  }
#
class pxc::server (
	$config_hash      = 	{},
	$enabled          = 	true,
	$manage_service   = 	true,
	$package_ensure   = 	$mysql::package_ensure,
	$package_name     = 	'Percona-XtraDB-Cluster-server-56',
	$client_package_name = 	'Percona-XtraDB-Cluster-client-56',
	$galera_package_name = 	'Percona-XtraDB-Cluster-galera-3',
	$mysql51_libs_package = 'Percona-Server-shared-51',
	$service_name     = 	'mysql',
	$service_provider = 	$mysql::service_provider,
	$wsrep_node_name     =  undef,
	$wsrep_node_address  =  undef,
	$wsrep_provider		 = 	'/usr/lib64/libgalera_smm.so',
	$wsrep_provider_options		 = 	'gcs.fc_limit=512',
	$wsrep_cluster_name  = 	'mycluster',
	$wsrep_cluster_address = 'gcomm://',
	$wsrep_slave_threads =  4,
	$wsrep_sst_method    = 	'xtrabackup',
	$wsrep_sst_username  = 	'sst',
	$wsrep_sst_password  = 	'secret',
) inherits mysql {

	# Class['pxc::server'] -> Class['mysql::config']

	$config_hash['service_name'] = $service_name
	$config_class = { 'mysql::config' => $config_hash }
	create_resources( 'class', $config_class )

	yumrepo {
	   "percona":
	   descr       => "Percona",
	   enabled     => 1,
	   baseurl     => "http://repo.percona.com/centos/6/os/$hardwaremodel/",
	   gpgcheck    => 1;
	}

	package { 
	'mysql-server':
	    ensure => $package_ensure,
	    name   => $package_name;
	'galera':
		ensure => $package_ensure,
		name   => $galera_package_name;
	'mysql51-libs':
		ensure => $package_ensure,
		name   => $mysql51_libs_package;
	}
	
	# Override base mysql client with our client
	Package['mysql_client'] {
		name => $client_package_name
	}
	
	
	Yumrepo['percona'] -> Package['mysql51-libs'] -> Package['galera'] -> Package['mysql-server']
	 

    file { 
		'pxc-config':
			name => '/etc/mysql/conf.d/pxc.cnf',
			ensure  => present,
			mode    => '0644',
			owner   => 'root',
			group   => $root_group,
			content => template('pxc/pxc.cnf.erb'),
			notify  => Service['mysqld'];
     }
	 # Class['mysql::config'] -> File['pxc-config']

	if $enabled {
	  $service_ensure = 'running'
	} else {
	  $service_ensure = 'stopped'
	}

	if $manage_service {
	    Service['mysqld'] -> Exec<| title == 'set_mysql_rootpw' |>
		
		service { 'mysqld':
			ensure   => $service_ensure,
			name     => $service_name,
			enable   => $enabled,
			require  => Package['mysql-server'],
			provider => $service_provider,
		}
	}
  
}
