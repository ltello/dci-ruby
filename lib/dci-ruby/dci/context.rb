require 'dci-ruby/dci/role'

module DCI

  class Context

    class << self

      # Every subclass of Context has is own class and instance method roles defined.
      # The instance method delegates value to the class.
      def inherited(subklass)
        subklass.class_eval do
          @roles ||= {}
          def self.roles; @roles end
          def roles; self.class.roles end
        end
      end


      private

        # The macro role is defined to allow a subclass of Context to define roles in its definition.
        # Every new role redefines the role class method to contain a hash accumulating all defined roles in that subclass.
        # An accessor to the object playing the new role is also defined and available in every instance of the context subclass.
        def role(role_key, &block)
          raise "role name must be a symbol" unless role_key.is_a?(Symbol)
          new_klass_name = role_key.to_s.split(/\_+/).map(&:capitalize).join('')
          const_set(new_klass_name, Class.new(::DCI::Role, &block))
          roles.merge!(role_key => const_get(new_klass_name.to_sym))
          attr_reader role_key
          private role_key
        end

    end


    # Instances of a defined subclass of Context are initialized checking first that all subclass defined roles
    # are provided in the creation invocation raising an error if any of them is missing.
    # Once the previous check is met, every object playing in the context instance is associated to the stated role.
    # Non players args are associated to instance_variables and readers defined.
    def initialize(args={})
      check_all_roles_provided_in!(args)
      players, noplayers = args.partition {|key, value| roles.has_key?(key)}.map {|group| Hash[*group.flatten]}
      assign_roles_to_players(players)
      define_readers_for_no_players(noplayers)
    end


    private

      # Checks there is a player for each role.
      # Raises and error message in case of missing roles.
      def check_all_roles_provided_in!(players={})
        missing_roles = missing_roles(players)
        raise "missing roles #{missing_roles}" unless missing_roles.empty?
      end

      # The list of roles with no player provided
      def missing_roles(players={})
        (roles.keys - players.keys)
      end

      # Associates every role to the intended player.
      def assign_roles_to_players(players={})
        roles.keys.each do |role_key|
          assign_role_to_player(role_key, players[role_key])
        end
      end

      # Associates a role to an intended player:
      #   - A new role instance is created from the associated role_key class and the player to get that role.
      #   - The new role instance has access to the context it is playing.
      #   - The new role instance has access to the rest of players in its context through instance methods named after their role keys.
      #   - The context instance has access to this new role instance through an instance method named after the role key.
      def assign_role_to_player(role_key, player)
        role_klass      = roles[role_key]
        other_role_keys = roles.keys - [role_key]
        role_instance   = role_klass.new(:player => player, :context => self, :role_mate_keys => other_role_keys)
        instance_variable_set(:"@#{role_key}", role_instance)
      end

      # For each given pair in vars, define a private method named the key that returns the entry associated value.
      def define_readers_for_no_players(vars={})
        vars.each do |name, value|
          instance_variable_set(:"@#{name}", value)
          singleton_class.class_exec(name.to_sym) do |varkey|
            private
              attr_reader varkey
          end
        end
      end

  end

end
