class pxc::config inherits mysql::config {

	Exec['mysqld-restart'] {
		command => "service ${service_name} restart"
	}

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
}