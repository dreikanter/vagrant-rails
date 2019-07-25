CONF = {
  APP_NAME: 'sampleapp',
  HOSTNAME: 'sampleapp.local',
  HOSTNAME_ALIASES: [],
  IP: '192.168.99.99',
  NODE_VERSION: 10,
  PLUGINS: [
    ['vagrant-vbguest', '0.18.0'],
    ['vagrant-hostmanager', '1.8.9'],
    ['vagrant-fsnotify', '0.3.1']
  ],
  PORTS: [
    { guest: 3000, host: 3000 },
    { guest: 8080, host: 8080 }
  ],
  POSTGRES_VERSION: 11,
  RUBY_VERSION: '2.6.3',
  SYNC_FOLDER_EXCLUDE: %w[
    .git/
    node_modules/
    tmp/
    coverage/
  ],
  SYNC_FOLDER_GUEST: '/app',
  SYNC_FOLDER_HOST: '.',
  VM_BOX: 'bento/ubuntu-19.04',
  VM_CPUS: 2,
  VM_RAM: 4096
}.freeze

Vagrant.require_version '>= 2.2'

CONF[:PLUGINS].each do |plugin, version|
  next if Vagrant.has_plugin?(plugin)
  cmd = "vagrant plugin install #{plugin} --plugin-version #{version}"
  system(cmd) || exit!
end

Vagrant.configure('2') do |config|
  config.vm.provider :virtualbox do |vb, _override|
    vb.memory = CONF[:VM_RAM]
    vb.cpus = CONF[:VM_CPUS]
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.customize [ 'guestproperty', 'set', :id, '--timesync-threshold', 10000 ]
    vb.gui = false
  end

  config.vbguest.auto_update = false
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.synced_folder(CONF[:SYNC_FOLDER_HOST], CONF[:SYNC_FOLDER_GUEST], fsnotify: true, exclude: CONF[:SYNC_FOLDER_EXCLUDE])

  config.vm.define CONF[:APP_NAME] do |machine|
    config.vm.box = CONF[:VM_BOX]
    machine.vm.hostname = CONF[:HOSTNAME]

    CONF[:PORTS].each do |ports|
      machine.vm.network('forwarded_port', auto_correct: true, **ports)
    end

    machine.vm.network('private_network', ip: CONF[:IP])
    machine.hostmanager.aliases = CONF[:HOSTNAME_ALIASES]
    config.vm.provision(:shell, path: 'provision.sh', privileged: false, env: CONF)
  end

  config.ssh.forward_agent = true

  # Prevent tty errors
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
end
