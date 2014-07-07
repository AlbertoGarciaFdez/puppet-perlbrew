class perlbrew (

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

  exec { 'install_perlbrew':
    command   => 'sudo apt-get install perlbrew -y',
    provider  => 'shell',
    user      => $user,
    creates   => '/usr/bin/perlbrew'
  }

  exec { 'set_source':
    cwd       => "/home/${user}",
    command   => "perlbrew init; /bin/echo \'source ~/perl5/perlbrew/etc/bashrc\' >> /home/${user}/.bashrc",
    unless    => "/bin/grep \'source ~/perl5/perlbrew/etc/bashrc\' /home/$user/.bashrc",
    user      => $user,
    provider  => 'shell',
    require   => Exec['install_perlbrew'],
    before    => Exec['install_perl_version'],
  }

  define install_perl {
    exec { 'install_perl_version':
      command   => "perlbrew install ${name}",
      user      => $user,
      creates   => "/home/$user/perl5/perlbrew/perls/perl-${name}/bin/perl",
      provider  => 'shell',
      before    => Exec['set_perl'],
      timeout   => '0',
    }
  }

  install_perl { $perl:}

  exec { 'set_perl':
    command   => "perlbrew switch perl-${perl_use}",
    provider  => 'shell',
    user      => $user,
    creates   => "/root/perl5/perlbrew/perls/${perl_use}/bin/perl",
  }

  exec { 'install_cpanm':
    command   => 'perlbrew install-cpanm',
    require   => Exec['set_perl'],
    user      => $user,
    provider  => 'shell',
    creates   => "/home/${user}/perl5/perlbrew/bin/cpanm",
    timeout   => '0',
  }

  exec { 'install_modules':
    command   => "cpanm ${perl_modules}",
    user      => $user,
    provider  => 'shell',
    require   => Exec['install_cpanm'],
    timeout   => '0',
  }
}
