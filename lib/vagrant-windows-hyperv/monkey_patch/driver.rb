require "#{Vagrant::source_root}/plugins/providers/hyperv/driver"

module VagrantPlugins
  module HyperV
    class Driver
      def import(options)
        loat_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        script_path = loat_path.join('import_vm.ps1').to_s
        execute(script_path, options)
      end
    end
  end
end
