#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

require "log4r"

module VagrantPlugins
  module HyperV
    module Action
      class Customize

        def initialize(app, env, event)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::connection")
          @event = event
        end

        def call(env)
          customizations = []
          @env = env
          env[:machine].provider_config.customizations.each do |event, command|
            if event == @event
              customizations << command
            end
          end
          if !customizations.empty?
            env[:ui].info I18n.t("vagrant.actions.vm.customize.running", event: @event)
            customizations.each do |query|
              command = query[0]
              params = query[1]
              if self.respond_to?("custom_action_#{command}")
                self.send("custom_action_#{command}", params)
              end
            end
          end
          validate_virtual_switch

          @app.call(env)
        end

        def custom_action_memory(memory)
          return if memory.nil? || memory.to_i == 0
          options = { vm_id: @env[:machine].id,
                      ram_memory: memory
                    }
          @env[:machine].provider.driver.execute('assign_memory.ps1', options)
        end

        def custom_action_virtual_switch(params)
          options = { vm_id: @env[:machine].id,
                      type: (params[:type] || "").downcase  || "external",
                      name: params[:name],
                      adapter: (params[:bridge] || "").downcase
                    }
          if options[:type] == "external"
            adapters = env[:machine].provider.driver.list_net_adapters
            available_adapters = adapters.map { |a| a["Name"].downcase }
            unless available_adapters.include? (options[:adapter])
              options[:adapter] = choose_option_from(adapters, "adapter")["Name"]
            end
          end
          response = @env[:machine].provider.driver.create_network_switch(options)
        end

        def validate_virtual_switch
          current_vm_switch = @env[:machine].provider.driver.find_vm_switch_name
          if current_vm_switch["network_adapter"].nil?
            # TODO:  Create a error class in core vagrant when merged.
            raise VagrantPlugins::VagrantHyperV::Errors::NoNetworkAdapter
          end

          if current_vm_switch["switch_name"].nil?
            switches = @env[:machine].provider.driver.execute("get_switches.ps1", {})
            raise Errors::NoSwitches if switches.empty?

            switch = choose_option_from(switches, "adapter")
            options = { vm_id: @env[:machine].id,
                        type: switch["SwitchType"].downcase,
                        name: switch["Name"],
                        adapter: switch["NetAdapterInterfaceDescription"]
                      }
            @env[:machine].provider.driver.create_network_switch(options)
          end
        end

        private

        def choose_option_from(options, key)
          if options.length > 1
            env[:ui].detail(I18n.t("vagrant_hyperv.choose_#{key}") + "\n ")
            options.each_index do |i|
              option = options[i]
              env[:ui].detail("#{i+1}) #{option["Name"]}")
            end
            env[:ui].detail(" ")

            selected = nil
            while !selected
              selected = env[:ui].ask("What #{key} would you like to use? ")
              next if !selected
              selected = selected.to_i - 1
              selected = nil if selected < 0 || selected >= options.length
            end
            options[selected]
          end
        end
      end
    end
  end
end
