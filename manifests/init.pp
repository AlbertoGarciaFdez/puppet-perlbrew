class perlbrew (

  $perl,
  $perl_use,
  $bundle,
  $cpanm_modules,
  $debian_packages,
  $user

  ) {

  package { $debian_packages: ensure  => latest,}

  exec { 'install_perlbrew':
    command   => 'sudo apt-get install perlbrew -y',
    provider  => 'shell',
    user      => "${user}",
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
    command   => "/bin/echo \'source ~/perl5/perlbrew/etc/bashrc\' >> /home/${user}/.bashrc",
    unless    => "/bin/grep \'source ~/perl5/perlbrew/etc/bashrc\' /home/${user}/.bashrc",
    user      => "${user}",
    provider  => 'shell',
    require   => Exec['set_environment'],
  }

  define install_perl {
    exec { "install_perl_version_${name}":
      command     => "/bin/su ${perlbrew::user} -c - \"source /home/${perlbrew::user}/perl5/perlbrew/etc/bashrc; perlbrew install ${name}\"",
      creates     => "/home/${perlbrew::user}/perl5/perlbrew/perls/perl-${name}/bin/perl",
      require     => Exec['set_source'],
      timeout     => '0',
    }
  }

  install_perl { $perl:}

  exec { 'set_perl':
    command   => "/bin/su ${user} -c - \"source /home/${user}/perl5/perlbrew/etc/bashrc; perlbrew switch perl-${perl_use}\"",
    require   => Install_perl[$perl],
    unless    => "/bin/su ${user} -c - \"source /home/${user}/perl5/perlbrew/etc/bashrc; which perl | grep ${perl_use}\"",
  }

  exec { 'install_cpanm':
    command   => "/bin/su ${user} -c - \"source /home/${user}/perl5/perlbrew/etc/bashrc; perlbrew install-cpanm\"",
    require   => Exec['set_perl'],
    creates   => "/home/${user}/perl5/perlbrew/bin/cpanm",
    timeout   => '0',
  }

  define install_modules {
    exec { "install_module_${name}":
      cwd       => "/home/${perlbrew::user}",
      command   => "/bin/su ${perlbrew::user} -c - \"source /home/${perlbrew::user}/perl5/perlbrew/etc/bashrc; cpanm ${name}\"",
      require   => Exec['install_cpanm'],
      timeout   => '0',
    }
  }

  if ($cpanm_modules != 'false') { install_modules { $cpanm_modules: } }

  if ($bundle != 'false') {

    file { 'bundle':
      path    => "/home/${user}/.cpan/Bundle/bundle",
      source  => "puppet:///$bundle",
      user    => $user,
      group   => $user,
    }

    exec { 'install_bundle':
      command => "bin/su ${perlbrew::user} -c - \"source /home/${perlbrew::user}/perl5/perlbrew/etc/bashrc; perl -MCPAN -e 'install Bundle::bundle'\"",
      timeout => '0',
    }
  }
}
