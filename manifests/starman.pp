class perlbrew::starman (

  $scripts,
  $workers,
  $user,
  $group,
  $app

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
}
