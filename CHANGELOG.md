## 1.0.3 (Unreleased)

FEATURES

#### Customization for Virtual Switch
  - Add customization for adding virtual switch. User can choose either External or
    Internal switch which will be attached to the VM on `vagrant up` or `vagrant reload`
    - **NOTE:** Vagrant works best with External switch, if you are using an Internal switch
    make sure the switch is properly configured for vagrant to communicate with the VM and
    the VM back to the host.
    - Example for configuration
      NOTE:
      If the adapter part if left blank, a list of available adapters will be displayed
      and the desired adapter can be selected.

      ```ruby
      config.vm.provider "hyperv" do |hv|
        hv.customize  ["virtual_switch", { type: "External", name: "External Switch", :adapter => "Ethernet" }]
      end
      ```

IMPROVEMENTS

  - Better error messages for PowerShell communication fails.
  - Better exception handling for PowerShell sessions.

BUGFIXES

  - Fix module path for Puppet manifests.
  - Fix race condition while enabling Guest Services [GH-61]

## Previous

See git commit
