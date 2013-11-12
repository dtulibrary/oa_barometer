include vagrant_hosts

class {'apache2':
  disable_default_vhost => true,
}

class {'oa_barometer': 
  rails_env  => 'staging',
  conf_set   => 'vagrant',
  vhost_name => 'oabarometer.vagrant.vm',
}
