# == Class: hiera::eyaml
#
# This class installs and configures hiera-eyaml
#
# === Authors:
#
# Terri Haber <terri@puppetlabs.com>
#
# === Copyright:
#
# Copyright (C) 2014 Terri Haber, unless otherwise noted.
#
class hiera::eyaml (
  $provider = $hiera::params::provider,
  $private_key_content = undef,
  $public_key_content  = undef,
  $owner    = $hiera::owner,
  $group    = $hiera::group,
  $cmdpath  = $hiera::cmdpath,
  $confdir  = $hiera::confdir
) inherits hiera::params {

  package { 'hiera-eyaml':
    ensure   => installed,
    provider => $provider,
  }

  file { "${confdir}/keys":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    before => Exec['createkeys'],
  }

  if $private_key_content {
      file { "${confdir}/keys/private_key.pkcs7.pem":
        ensure  => file,
        content => $private_key_content,
        mode    => '0600',
        owner   => $owner,
        group   => $group,
        require => File["${confdir}/keys"],
      }
      if $public_key_content {
        file { "${confdir}/keys/public_key.pkcs7.pem":
          ensure  => file,
          content => $public_key_content,
          mode    => '0644',
          owner   => $owner,
          group   => $group,
          require => File["${confdir}/keys"],
        }
      }
  } else {
    exec { 'createkeys':
      user    => $owner,
      cwd     => $confdir,
      command => 'eyaml createkeys',
      path    => $cmdpath,
      creates => "${confdir}/keys/private_key.pkcs7.pem",
      require => Package['hiera-eyaml'],
    }

    file { "${confdir}/keys/private_key.pkcs7.pem":
      ensure  => file,
      mode    => '0600',
      owner   => $owner,
      group   => $group,
      require => Exec['createkeys'],
    }

    file { "${confdir}/keys/public_key.pkcs7.pem":
      ensure  => file,
      mode    => '0644',
      owner   => $owner,
      group   => $group,
      require => Exec['createkeys'],
    }
  }
}
