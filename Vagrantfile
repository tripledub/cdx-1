# -*- mode: ruby -*-
# # vi: set ft=ruby :
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use Ubuntu 14.04 Trusty Tahr 64-bit as our operating system
  config.vm.box = 'ubuntu/trusty64'

  # Configurate the virtual machine to use 2GB of RAM
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '2048']
  end

  # Forward the Rails server default port to the host
  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.vm.provision 'fix-no-tty', type: 'shell' do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.version = '12.10.24'
    chef.cookbooks_path = ['cookbooks']
    chef.add_recipe :apt
    chef.add_recipe 'redis::server'
    chef.add_recipe 'nodejs'
    chef.add_recipe 'mysql::server'
    chef.add_recipe 'mysql::client'
    chef.add_recipe 'vim'
    chef.add_recipe 'ruby_build'
    chef.add_recipe 'rbenv::user'
    chef.add_recipe 'phantomjs'
    chef.add_recipe 'java'

    # Install Ruby 2.1.5 and Bundler
    # Set an empty root password for MySQL to make things simple
    chef.json = {
      redis: {
        bind: '0.0.0.0',
        port: '6379',
        config_path: '/etc/redis/redis.conf',
        daemonize: 'yes',
        timeout: '300',
        loglevel: 'notice',
        socket: '/tmp/redis.sock',
        create_service: true
      },
      java: {
        jdk_version: 7,
      },
      rbenv: {
        user_installs: [{
          user: 'vagrant',
          rubies: ['2.1.5'],
          global: '2.1.5',
          gems: {
            '2.1.5' => [
              { name: 'bundler' }
            ]
          }
        }]
      },
      mysql: {
        server_root_password: '',
        server_repl_password: '',
        server_debian_password: '',
        service_name: 'mysql',
        basedir: '/usr',
        data_dir: '/var/lib/mysql',
        root_group: 'root',
        mysqladmin_bin: '/usr/bin/mysqladmin',
        mysql_bin: '/usr/bin/mysql',
        conf_dir: '/etc/mysql',
        confd_dir: '/etc/mysql/conf.d',
        socket: '/var/run/mysqld/mysqld.sock',
        pid_file: '/var/run/mysqld/mysqld.pid',
        grants_path: '/etc/mysql/grants.sql'
      }
    }
  end
end
