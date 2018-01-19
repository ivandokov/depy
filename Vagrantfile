Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip: "192.168.20.20"
  config.ssh.insert_key = true
  config.ssh.forward_agent = true
  config.vm.provision "shell" do |s|
    s.inline = "echo $1 | tee -a /home/ubuntu/.ssh/authorized_keys"
    s.args = [File.read(File.expand_path("~/.ssh/id_rsa.pub"))]
  end
end
