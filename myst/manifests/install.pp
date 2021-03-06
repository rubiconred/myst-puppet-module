# == Class: myst::install
#
# Module to install an up-to-date version of MyST
# 
class myst::install inherits myst {
  $myst_response_file='/tmp/myst-response.xml'
  file { $myst_response_file:
    ensure  => present,
    content => template('myst/myst-response.xml.erb'),
  }
  $myst_install_file='/tmp/myst.jar'
  file { $myst_install_file:
    ensure => present,
    source => $::myst_installer
  }
  Exec {
    path => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'
  }
  if $::package_ensure == installed {
    exec { 'install-myst':
      command => "java -jar ${myst_install_file} ${myst_response_file}",
      require => [File[$myst_response_file],File[$myst_install_file]],
      before  => File[$::myst_home],
    }
  } elsif $::package_ensure == absent {
    exec { 'uninstall-myst':
      command => "java -jar ${::myst_home}/Uninstaller/uninstaller.jar -c -f",
      onlyif  => "test -f ${::myst_home}/Uninstaller/uninstaller.jar",
    }
  }
  file { $::myst_home:
    ensure  => directory,
    require => Exec['install-myst'],
  }
}