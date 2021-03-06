class simple-deployment {
	$site_name = 'simple-deployment'
	$site_domain = 'simple-deployment.com'

	
	git::clone { 'https://github.com/tnh/simple-sinatra-app':
		path => '/var/www',
		dir => $site_name,
	}

	service { 'simpledeployd':
		ensure => running,
		enable => true,
		loglevel => info,
		require => [
			Exec['site-install'], 
			File['/etc/init.d/simpledeployd'],
			File["/etc/nginx/sites-enabled/${site_name}"],
		],
	}
	
	exec { 'site-install':
		cwd => "/var/www/${site_name}",
		path => "/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
		command => 'bundle install',
		provider => shell,
		user => "root",
		group => "root",
		logoutput => true,
		environment => [
			"HOME=/root",
			"LOGNAME=root",
			"USER=root",
		],
		require => [
			File['/var/www'],
			Git::Clone['https://github.com/tnh/simple-sinatra-app'],
			Package['bundler'],
		],
	}	
	
	file { '/etc/init.d/simpledeployd':
		ensure => file,
		content => template('simple-deployment/simple-deployment-daemon'),
		mode => 777,
		require => Exec['site-install'], 
	}	

	file { "/etc/nginx/sites-available/${site_name}":
		ensure => file,
		content => template('simple-deployment/nginx-site.conf.erb'),
		notify => Service['nginx'],
		require => [
			Package['nginx'],
			File['/var/www'],
		],
	}
	
	file { "/etc/nginx/sites-enabled/${site_name}":
		ensure => link,
		target => "/etc/nginx/sites-available/${site_name}",
		require => [
			File["/etc/nginx/sites-available/${site_name}"]
		],
		notify => Service['nginx'],
	}	

	file { "/usr/bin/${site_name}":
		ensure => file,
		content => template('simple-deployment/exec-simple-deployment'),
		mode => 777,
		notify => Service['simpledeployd'],
		require => [
			Exec['site-install'],
			File['/etc/init.d/simpledeployd'],
		],
	}	

}
