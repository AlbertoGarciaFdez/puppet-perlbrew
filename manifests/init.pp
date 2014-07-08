class perlbrew (

  $perl,
  $perl_use,
  $perl_modules,
  $debian_packages,
  $user,

  ) {

  package { $debian_packages: ensure  => latest,}

  exec { 'install_perlbrew':
    command   => 'sudo apt-get install perlbrew -y',
    provider  => 'shell',
    user      => $user,
    creates   => '/usr/bin/perlbrew',
    require   => Package[$debian_packages],
  }

  exec { 'set_environment':
    cwd       => "/home/${user}",
    command   => '/bin/sh -c perlbrew init',
    creates   => "/home/$user/perl5",
    user      => $user,
    provider  => 'posix',
    require   => Exec['install_perlbrew'],
  }

  exec {'set_source':
    cwd       => "/home/${user}",
    command   => "/bin/echo \'source ~/perl5/perlbrew/etc/bashrc\' >> /home/${user}/.bashrc",
    unless    => "/bin/grep \'source ~/perl5/perlbrew/etc/bashrc\' /home/${user}/.bashrc",
    user      => $user,
    provider  => 'shell',
    require   => Exec['set_environment'],
  }

  define install_perl {
    exec { "install_perl_version-${name}}":
      command     => "/bin/sh -c \'perlbrew init && perlbrew install ${name}\'",
      user        => $perlbrew::user,
      environment => "HOME=/home/${user}",
      creates     => "/home/${user_define}/perl5/perlbrew/perls/perl-${name}/bin/perl",
      provider    => 'posix',
      require     => Exec['set_source'],
      timeout     => '0',
    }
  }

  install_perl { $perl:}

  exec { 'set_perl':
    command   => "/bin/sh -c \'perlbrew switch perl-${perl_use}\'",
    provider  => 'posix',
    user      => $user,
    creates   => "/root/perl5/perlbrew/perls/${perl_use}/bin/perl",
    require   => Install_perl[$perl],
  }

  exec { 'install_cpanm':
    command   => '/bin/sh -c \'perlbrew install-cpanm\'',
    require   => Exec['set_perl'],
    user      => $user,
    provider  => 'posix',
    creates   => "/home/${user}/perl5/perlbrew/bin/cpanm",
    timeout   => '0',
  }

  exec { 'install_modules':
    command   => "/bin/sh -c \'cpanm ${perl_modules}\'",
    user      => $user,
    provider  => 'posix',
    require   => Exec['install_cpanm'],
    timeout   => '0',
  }
}
