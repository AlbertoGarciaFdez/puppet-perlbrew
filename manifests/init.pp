class perlbrew (

  $perl,
  $perl_use,
  $perl_modules

  ) {

  package { 'build-essential':
    ensure  => latest,
    before  => Exec['install_perlbrew'],
 }

  package { 'curl':
    ensure  => latest,
    before  => Exec['install_perlbrew'],
  }

  exec { 'install_perlbrew':
    command => '/usr/bin/curl -L http://install.perlbrew.pl | /bin/bash; /root/perl5/perlbrew/bin/perlbrew init',
    creates => '/root/perl5/perlbrew/bin/perlbrew',
    timeout => '0',
  }

  file_line { 'edit bashrc':
    path    => '/root/.bashrc',
    line    => 'source ~/perl5/perlbrew/etc/bashrc',
    require => Exec['install_perlbrew'],
    before  => Exec['install_perl_version'],
  }

  define install_perl {
    exec { 'install_perl_version':
      command => "/root/perl5/perlbrew/bin/perlbrew install ${name}",
      creates => "/root/perl5/perlbrew/perls/perl-${name}/bin/perl",
      require => Exec['install_perlbrew'],
      before  => Exec['set_perl'],
      timeout => '0',
    }
  }

  install_perl { $perl:}

  exec { 'set_perl':
    command => "/root/perl5/perlbrew/bin/perlbrew switch perl-${perl_use}",
    unless  => "/usr/bin/test -f /root/perl5/perls/${name}/bin/perl",
  }

  exec { 'install_cpanm':
    command => '/root/perl5/perlbrew/bin/perlbrew install-cpanm',
    require => Exec['set_perl'],
    unless  => '/usr/bin/test -f /root/perl5/perlbrew/bin/cpanm',
    timeout => '0',
  }

  exec { 'install_modules':
    command => "/root/perl5/perlbrew/bin/cpanm ${perl_modules}",
    require => Exec['install_cpanm'],
    timeout => '0',
  }
}
