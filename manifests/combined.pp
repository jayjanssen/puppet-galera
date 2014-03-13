class { 'pxc::server':
	config_hash => {
		root_password => 'r00t',
		pidfile => 'mysqld.pid',
		bind_address => '0.0.0.0',
		query_cache_size => 0,
		query_cache_limit => 0
	}
}

# include galera::monitor