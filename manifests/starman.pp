class perlbrew::starman (

  $scripts,
  $workers,
  $user,
  $group

) {

  file {'/etc/init.d/starman':
    mode    => 744,
    content => template('perlbrew/starman.erb'),
    notify  => Service['starman']
  }

  exec {'add_daemon':
    command => '/usr/sbin/update-rc.d starman defaults',
    cwd => '/etc/init.d',
    require => File ['/etc/init.d/starman']
  }

  service {'starman':
    enable      => true,
    ensure      => running,
    hasrestart  => true,
    require     => Exec['add_daemon'],
  }

  #Module sudo https://github.com/example42/puppet-sudo required
  sudo::directive { "${user}":
    content =>  "${user} ALL=NOPASSWD: /etc/init.d/starman",
  }
}
