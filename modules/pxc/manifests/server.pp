
# Class: pxcThis mea::server

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
