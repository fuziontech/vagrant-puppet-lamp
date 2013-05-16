exec { 'apt-get update' :
    command => 'apt-get update',
    path    => '/usr/bin/',
    timeout => 60,
    tries   => 3
}

class { 'apt' :
    always_apt_update => true
}

package { ['build-essential', 'python-software-properties',
           'vim', 'curl', 'git', 'subversion', 'zip'] :
    ensure  => 'installed',
    require => Exec['apt-get update'],
}

file { '/home/vagrant/.bash_aliases' :
    source => 'puppet:///modules/puphpet/dot/.bash_aliases',
    ensure => 'present',
}

apt::ppa { 'ppa:ondrej/php5' : }

class { 'git' :
    svn => true,
    gui => false,
}

class { 'apache' :
    require => Apt::Ppa['ppa:ondrej/php5'],
}

apache::dotconf { 'custom' :
    content => 'EnableSendfile Off',
}

apache::module { 'rewrite' : }

apache::vhost { 'invoise' :
    server_name   => 'invoise.dev',
    serveraliases => ['www.invoise.dev'],
    docroot       => '/var/www/invoi.se/web',
    port          => '80',
    priority      => '1'
}

apache::vhost { 'jtreminio' :
    server_name   => 'jtreminio.dev',
    serveraliases => ['www.jtreminio.dev'],
    docroot       => '/var/www/jtreminio.com/website',
    port          => '80',
    priority      => '1'
}

apache::vhost { 'puphpet' :
    server_name   => 'puphpet.dev',
    serveraliases => ['www.puphpet.dev'],
    docroot       => '/var/www/puphpet/web',
    port          => '80',
    env_variables => ['APP_ENV dev'],
    priority      => '1'
}

class { 'php' :
    service => 'apache',
    require => Package['apache'],
}

php::module { 'php5-cli' : }
php::module { 'php5-curl' : }
php::module { 'php5-intl' : }
php::module { 'php5-mcrypt' : }
php::module { 'php5-mysql' : }

class { 'php::pear' :
    require => Class['php'],
}

class { 'php::devel' :
    require => Class['php'],
}

php::pecl::module { 'pecl_http' :
    use_package => false
}

php::ini { 'default' :
    value  => [
        'date.timezone = America/Chicago',
        'display_errors = On',
        'error_reporting = -1'
    ],
    target => 'error_reporting.ini'
}

class { 'xdebug' : }

xdebug::config { 'cgi' : }
xdebug::config { 'cli' : }

class { 'mysql' :
    root_password => $mysql_root_password,
}
