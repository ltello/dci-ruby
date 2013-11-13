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

      # A short way for ContextSubclass.new(players_and_extra_args).run(extra_args)
      def [](*args)
        new(*args).run
      end


      private

        # The macro role is defined to allow a subclass of Context to define roles in its definition body.
        # Every new role is added to the hash of roles in that Context subclass.
        # A reader to access the object playing the new role is also defined and available in every instance of the context subclass.
        # Also, readers to allow each other role access are defined.
        def role(rolekey, &block)
          raise "role name must be a symbol" unless rolekey.is_a?(Symbol)
          create_role_from(rolekey, &block)
          define_reader_for_role(rolekey)
          define_mate_roleplayers_readers_after_newrole(rolekey)
        end

        # Adds a new entry to the roles accumulator hash.
        def create_role_from(key, &block)
          roles.merge!(key => create_role_subclass_from(key, &block))
        end

        # Defines and return a new subclass of DCI::Role named after the given rolekey and with body the given block.
        def create_role_subclass_from(rolekey, &block)
          new_klass_name = rolekey.to_s.split(/\_+/).map(&:capitalize).join('')
          const_set(new_klass_name, Class.new(::DCI::Role, &block))
        end

        # Defines a private reader to allow a context instance access to the roleplayer object associated to the given rolekey.
        def define_reader_for_role(rolekey)
          attr_reader rolekey
          private rolekey
        end

        # After a new role is defined, you've got to create a reader method for this new role in the rest of context
        # roles, and viceverse: create a reader method in the new role klass for each of the other roles in the context.
        # This method does exactly this.
        def define_mate_roleplayers_readers_after_newrole(new_rolekey)
          new_roleklass = roles[new_rolekey]
          mate_roles    = mate_roles_of(new_rolekey)
          mate_roles.each do |mate_rolekey, mate_roleklass|
            mate_roleklass.send(:add_role_reader_for!, new_rolekey)
            new_roleklass.send(:add_role_reader_for!, mate_rolekey)
          end
        end

        # For a give role key, returns a hash with the rest of the roles (pair :rolekey => roleklass) in the context it belongs to.
        def mate_roles_of(rolekey)
          roles.dup.tap do |roles|
            roles.delete(rolekey)
          end
        end

    end


    # Instances of a defined subclass of Context are initialized checking first that all subclass defined roles
    # are provided in the creation invocation raising an error if any of them is missing.
    # Once the previous check is met, every object playing in the context instance is associated to the stated role.
    # Non players args are associated to instance_variables and readers defined.
    def initialize(args={})
      check_all_roles_provided_in!(args)
      players, noplayers = args.partition {|key, *| roles.has_key?(key)}.map {|group| Hash[*group.flatten]}
      assign_roles_to_players(players)
      @settings = noplayers
    end


    private

      # Private access to the extra args received in the instantiation.
      def settings(*keys)
        return @settings.dup if keys.empty?
        entries = @settings.reject {|k, v| !keys.include?(k)}
        keys.size == 1 ? entries.values.first : entries
      end

      # Checks there is a player for each role.
      # Raises and error message in case of missing roles.
      def check_all_roles_provided_in!(players={})
        missing_rolekeys = missing_roles(players)
        raise "missing roles #{missing_rolekeys}" unless missing_rolekeys.empty?
      end

      # The list of roles with no player provided
      def missing_roles(players={})
        (roles.keys - players.keys)
      end

      # Associates every role to the intended player.
      def assign_roles_to_players(players={})
        roles.keys.each do |rolekey|
          assign_role_to_player(rolekey, players[rolekey])
        end
      end

      # Associates a role to an intended player:
      #   - A new role instance is created from the associated rolekey class and the player to get that role.
      #   - The new role instance has access to the context it is playing.
      #   - The new role instance has access to the rest of players in its context through instance methods named after their role keys.
      #   - The context instance has access to this new role instance through an instance method named after the role key.
      def assign_role_to_player(rolekey, player)
        role_klass    = roles[rolekey]
        role_instance = role_klass.new(:player => player, :context => self)
        instance_variable_set(:"@#{rolekey}", role_instance)
      end

  end
end
