# Vagrant Windows Hyper-V Provider

Vagrant is a tool for building complete development environments, sandboxed in a virtual machine. It helps enforce good practices by encouraging the use of automation so that development environments are as close to production as possible.

Hyper-V provider is available by default in Vagrant with version 1.5 and up. This plugin is created to provide windows guest support for the Vagrant Hyper-V provider.


## Installation
Install Vagrant 1.5.4
http://www.vagrantup.com/downloads.html


Install plugin like so:
vagrant plugin install vagrant-windows-hyperv


## Configuration settings
For more information on general configuration settings please visit the Vagrant Documentation.
http://docs.vagrantup.com/v2/


##Setting specific to this plugin

### Sync Folder configuration

With Vagrant 1.5 SMB share is available by default and vagrant picks the most suitable
implementation for the providers.

You can even specify the following options

 :smb_id   Specify a unique share name, with which the network share will be available. By default vagrant will generate a smb_id if not specified.




```ruby
   # Mounts the host/path to guest/path and will have realtime sync
    config.vm.synced_folder 'C:/test_sync_2', "C:/Users/vagrant/test_sync_2"

```
### VM Type
* Set the VM guest type

```ruby
config.vm.guest = :windows
```

### Override user name
* If you're building a custom box and want to customize the user name, you can use the hyper-v custom block to add it in

```ruby
config.vm.provider "hyperv" do |hv, override|
  override.ssh.username = "myuser"
end
```
### New RDP Command
* A new command vagrant rdp is introduced to connect to the Windows VM
` vagrant rdp `

### Customization
* Add customization for adding virtual switch. User can choose either External or
  Internal switch which will be attached to the VM on `vagrant up` or `vagrant reload`
  - **NOTE:** Vagrant works best with External switch, if you are using an Internal switch
  make sure the switch is properly configured for vagrant to communicate with the VM and
  the VM back to the host.
  - Example for configuration

    **NOTE:** If the adapter part if left blank, a list of available adapters will be displayed
    and the desired adapter can be selected.

    ```ruby
    config.vm.provider "hyperv" do |hv|
      hv.customize  ["virtual_switch", { type: "External", name: "External Switch", :adapter => "Ethernet" }]
    end
    ```

## Troubleshooting

### Remote PowerShell
Vagrant-Windows-HyperV uses remote PowerShell to communicate with the guest VMs, so the guest VMs should have WinRM service running and remote PowerShell running.

To Enable remote PowerShell in the guest.
Go to the guest VM, open a cmd terminal and type the following command
```
powershell Enable-PSRemoting –force
```
### Trustedhosts
With PowerShell being enabled in the remote VM, the host has to trust this guest to establish the connection.
One can add the guest IP under trustedhost. Here "*" can be used as a wildcard to trust all hosts, or replace the * with the IP address of the guest..

Type this command from an Administrator cmdshell prompt

`
powershell set-item wsman:\localhost\client\trustedhosts *
`

### SMB Share
There is a bug in the current vagrant release (1.5.1) you may run into collisions when you create shares. To avoid this, user smb_id option and make sure the share name does not collide with existing shares.

` config.vm.synced_folder 'C:/test_sync_2', "C:/Users/vagrant/test_sync_2", :smb_id => "test_my_share" `
