# loop to pull values from .env
if File.exist?(".env")
  File.foreach(".env") do |line|
    next if line.strip.start_with?("#") || line.strip.empty?
    key, value = line.strip.split("=", 2)
    ENV[key] = value.gsub(/\A['"]|['"]\z/, '') if key && value
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.boot_timeout = 3600

  devops_pub_key_path = File.expand_path("~/.ssh/devops_key.pub")
  devops_password = (ENV['DEVOPS_PASSWORD'] && !ENV['DEVOPS_PASSWORD'].empty?) ? ENV['DEVOPS_PASSWORD'] : (ARGV[0] != "destroy" && abort("ERROR: DEVOPS_PASSWORD not set. Add it to your .env file"))

  # devops_key required
  if ARGV[0] != "destroy"
    abort "ERROR: SSH public key not found at ~/.ssh/devops_key.pub" unless File.exist?(devops_pub_key_path)
  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
  end

  # VMs and their configurations
  vms = [
    { name: "loadbalancer", ip: "192.168.56.10", memory: "2048", cpus: 2, group: "loadbalancers" },
    { name: "webserver01",  ip: "192.168.56.11", memory: "1024", cpus: 1, group: "webservers" },
    { name: "webserver02",  ip: "192.168.56.12", memory: "1024", cpus: 1, group: "webservers" },
    { name: "appserver",    ip: "192.168.56.20", memory: "2048", cpus: 2, group: "appservers" },
    { name: "monitor",      ip: "192.168.56.40", memory: "4096", cpus: 2, group: "monitors" },
  ]

  groups = vms.group_by { |v| v[:group] }.transform_values { |v| v.map { |m| m[:name] } }

  # a loop to setup every VM and then start the provisioning with Ansible
  vms.each do |vm|
    config.vm.define vm[:name] do |node|
      node.vm.hostname = vm[:name]
      node.vm.network "private_network", ip: vm[:ip]
      node.vm.provider "virtualbox" do |vb|
        vb.name   = vm[:name]
        vb.memory = vm[:memory]
        vb.cpus   = vm[:cpus]
      end

      # Only trigger Ansible provisioner on the last VM
      if vm[:name] == vms.last[:name]
        node.vm.provision "ansible" do |ansible|
          ansible.playbook       = "ansible/site.yml"
          ansible.raw_arguments = ["--ssh-extra-args='-o StrictHostKeyChecking=no'"]
          ansible.limit          = "all"
          ansible.groups = groups
          ansible.extra_vars     = {
            devops_password: devops_password,
            apt_cache_url:   ENV['APT_CACHE_URL'] || "",
            grafana_password: ENV['GRAFANA_PASSWORD'] || "admin",
            discord_webhook_url: ENV['DISCORD_WEBHOOK_URL'] || ""
          }
        end
      end
    end
  end
end