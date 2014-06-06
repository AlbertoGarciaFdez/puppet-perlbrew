class perlbrew (

  $perl,
  $perl_use,
  $perl_modules

  ) {

  package { 'build-essential':
    ensure  => latest,
  }

  package { 'curl':
    ensure  => latest,
  }

  exec { 'install_perlbrew':
    command => '/usr/bin/curl -L http://install.perlbrew.pl | /bin/bash; /root/perl5/perlbrew/bin/perlbrew init',
    creates => '/root/perl5/perlbrew/bin/perlbrew',
    require => Package['build-essential'],
    require => Package['curl'],
  }

  define install_perl {
    exec { 'install_perl_version':
      command => "/root/perl5/perlbrew/bin/perlbrew install ${name}",
      creates => "/root/perl5/perls/${name}/bin/perl",
      require => Exec['install_perlbrew'],
      before  => Exec['set_perl'],
    }
  }

  install_perl { $perl:}

  exec { 'set_perl':
    command => "/root/perl5/perlbrew/bin/perlbrew switch perl-${perl_use}",
    unless  => "test -f /root/perl5/perls/${name}/bin/perl",
  }

  exec { 'install_cpanm':
    command => '/root/perl5/perlbrew/bin/perlbrew install-cpanm',
    require => Exec['set_perl'],
    unless  => 'test -f /root/perl5/perlbrew/bin/cpanm',
  }

  exec { 'install_modules':
    command => "/root/perl5/perlbrew/bin/cpanm ${perl_modules}"
    require => ['install_cpanm'],
  }
}
