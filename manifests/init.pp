class perlbrew (
1
  $perl,
  $perl_use,
  $perl_modules,
  $debian_packages,
  $user,

  ) {

  package { $debian_packages:
    ensure  => latest,
    before  => Exec['set_source'],
  }

  package { 'perlbrew': ensure  => latest }

  exec { 'set_source':
    command   => "/bin/echo \'source ~/perl5/perlbrew/etc/bashrc\' >> /home/${user}/.bashrc; /usr/bin/perlbrew init",
    unless    => "/bin/grep \'source ~/perl5/perlbrew/etc/bashrc\' /home/$user/.bashrc",
    user      => $user,
    provider  => 'shell',
    require   => Package['perlbrew'],
    before    => Exec['install_perl_version'],
  }

  define install_perl {
    exec { 'install_perl_version':
      command   => "/usr/bin/perlbrew install ${name}",
      user      => $user,
      creates   => "/home/$user/perl5/perlbrew/perls/perl-${name}/bin/perl",
      provider  => 'shell',
      before    => Exec['set_perl'],
      timeout   => '0',
    }
  }

  install_perl { $perl:}

  exec { 'set_perl':
    command   => "/usr/bin/perlbrew switch perl-${perl_use}",
    provider  => 'shell',
    user      => $user,
    unless    => "/usr/bin/test -f /root/perl5/perlbrew/perls/${perl_use}/bin/perl",
  }

  exec { 'install_cpanm':
    command   => '/usr/bin/perlbrew install-cpanm',
    require   => Exec['set_perl'],
    user      => $user,
    provider  => 'shell',
    unless    => "/usr/bin/test -f /home/${user}/perl5/perlbrew/bin/cpanm",
    timeout   => '0',
  }

  exec { 'install_modules':
    command   => "/usr/bin/perlbrew init;usr/bin/perlbrew switch perl-${perl_use}|/usr/bin/perlbrew/bin/cpanm ${perl_modules}",
    user      => $user,
    provider  => 'shell',
    require   => Exec['install_cpanm'],
    timeout   => '0',
  }
}
