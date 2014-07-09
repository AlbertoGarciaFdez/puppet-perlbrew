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
    command   => "/bin/su ${user} -c - \'perlbrew init\'",
    creates   => "/home/${user}/perl5",
    require   => Exec['install_perlbrew'],
  }

  exec {'set_source':
    cwd       => "/home/${user}",
    command   => "echo \'source ~/perl5/perlbrew/etc/bashrc\' >> /home/${user}/.bashrc",
    unless    => "grep \'source ~/perl5/perlbrew/etc/bashrc\' /home/${user}/.bashrc",
    user      => $user,
    provider  => 'shell',
    require   => Exec['set_environment'],
  }

  define install_perl {
    exec { "install_perl_version-${name}":
      command     => "/bin/su $perlbrew::user -c -\"source /home/${user}/perl5/perlbrew/etc/bashrc; perlbrew install ${name}\"",
      creates     => "/home/${perlbrew::user}/perl5/perlbrew/perls/perl-${name}/bin/perl",
      require     => Exec['set_source'],
      timeout     => '0',
    }
  }

  install_perl { $perl:}

  exec { 'set_perl':
    command   => "/bin/su $user -c -\"source /home/${user}/perl5/perlbrew/etc/bashrc; perlbrew switch perl-${perl_use}\"",
    require   => Install_perl[$perl],
  }

  exec { 'install_cpanm':
    command   => "/bin/su $user -c -\"source /home/${user}/perl5/perlbrew/etc/bashrc; perlbrew install-cpanm\"",
    require   => Exec['set_perl'],
    creates   => "/home/${user}/perl5/perlbrew/bin/cpanm",
    timeout   => '0',
  }

  exec { 'install_modules':
    command   => "/bin/su $user -c -\"source /home/${user}/perl5/perlbrew/etc/bashrc; cd \$HOME; cpanm ${perl_modules}\"",
    require   => Exec['install_cpanm'],
    timeout   => '0',
  }
}
