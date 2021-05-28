Vagrant.configure("2") do |config|

################# Configuration of vm-01 ##################
config.vm.define "vm-01" do |vm1|
	vm1.vm.box = "devops_lab/centos7" 					# Using custom Vagrant box with name CentOS7
	vm1.vm.hostname = "vm-01"				# Hostname of this VM
	vm1.vm.network "private_network", ip: "100.100.100.10"	# IP configuration
	vm1.vm.provider "virtualbox" do |vb|			# Provider config:	
		vb.name = "vm-01"				    # VM name that appears in VirtualBox GUI
		vb.memory = 512					    # Amount of RAM is used by the VM
	end
	vm1.vm.provision "shell", path: "./provision-vm-01.sh"  # Vagrant shell provissioner
end



################# Configuration of vm-02 ##################
config.vm.define "vm-02" do |vm2|				
        vm2.vm.box = "devops_lab/centos8"			# Using custom Vagrant box with name CentOS8
        vm2.vm.hostname = "vm-02"				# Hostname of this VM
        vm2.vm.network "private_network", ip: "100.100.100.11"	# IP configuration
	vm2.vm.provider "virtualbox" do |vb|			# Provider config:
                vb.name = "vm-02"				    # VM name that appears in VirtualBox GUI
                vb.memory = 512					    # Amount of RAM is used by the VM
	end       
	vm2.vm.provision "shell", path: "./provision-vm-02.sh"	# Vagrant shell provissioner
end

end
