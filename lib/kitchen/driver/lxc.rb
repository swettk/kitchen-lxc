require "kitchen"
require "elecksee/ephemeral"

::Lxc.use_sudo = true

module Kitchen

  module Driver

    class Lxc < Kitchen::Driver::SSHBase

      default_config :use_sudo, true
      default_config :username, "root" # most LXC templates use this
      default_config :password, "root" # most LXC templates use this

      default_config :original do |driver|
        driver[:base_container]
      end

      no_parallel_for :create

      def create(state)
        container = ::Lxc::Ephemeral.new(config.to_hash)
        container.create!

        state[:container_name] = container.name

        lxc = ::Lxc.new(state[:container_name])
        lxc.start

        state[:hostname] = lxc.container_ip(10, true)
        wait_for_sshd(state[:hostname])
      end

      def destroy(state)
        if state[:container_name]
          lxc = ::Lxc.new(state[:container_name])
          lxc.destroy
        end
      end

    end

    class LXC < Lxc; end

  end
end
