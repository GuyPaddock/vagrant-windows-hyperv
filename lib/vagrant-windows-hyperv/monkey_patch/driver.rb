#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "#{Vagrant::source_root}/plugins/providers/hyperv/driver"

module VagrantPlugins
  module HyperV
    class Driver

      # Override the existing import method to Override the import_vm.ps1 script
      def import(options)
        load_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        script_path = load_path.join('import_vm.ps1').to_s
        execute(script_path, options)
      end

      # New methods for network customization
      def create_network_switch(options)
        load_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        script_path = load_path.join('create_switch.ps1')
        execute(script_path, options)
      end

      def list_net_adapters
        load_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        script_path = load_path.join('get_adapters.ps1')
        execute(script_path, {})
      end

      def find_vm_switch_name
        load_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        script_path = load_path.join('find_vm_switch_name.ps1')
        execute(script_path, {vm_id: vm_id})
      end

      def add_swith_to_vm(options)
        load_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        script_path = load_path.join('add_switch_to_vm.ps1')
        execute(script_path, options)
      end

      def switch_exist(options)
        load_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        script_path = load_path.join('switch_exist.ps1')
        execute(script_path, options)
      end

    end
  end
end
