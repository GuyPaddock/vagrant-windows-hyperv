#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module HyperV
    module Action

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use CheckEnabled
          b.use HandleBox
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env1, b1|
            if env1[:result]
              b1.use Import
            end
            b1.use Customize, "pre-boot"
            b1.use action_start
          end
        end
      end

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            if env[:result]
              b2.use Message, I18n.t("vagrant_hyperv.message_not_created")
              next
            end

            b2.use action_halt
            b2.use Customize, "pre-boot"
            b2.use action_start
          end
        end
      end
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :Customize, action_root.join("customize")

    end
  end
end
