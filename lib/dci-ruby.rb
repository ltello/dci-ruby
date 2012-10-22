require 'forwardable'
require 'dci-ruby/kernel'


class Context

  # Every subclass of Context has is own class and instance method roles defined.
  # The instance method delegates value to the class.
  def self.inherited(subklass)
    subklass.class_eval do
      def self.roles; {} end
      def roles; self.class.roles end
    end
  end

  # The macro role is defined to allow a subclass of Context to define roles in its definition.
  # Every new role redefines the role class method to contain a hash accumulating all defined roles in that subclass.
  # An accessor to the object playing the new role is also defined and available in every instance of the context subclass.
  def self.role(role_key, &block)
    raise "role name must be a symbol" unless role_key.is_a?(Symbol)
    updated_roles = roles.merge(role_key => Module.new(&block))
    singleton_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      remove_method(:roles) rescue nil
      define_method(:roles) { #{updated_roles} }
    RUBY
    attr_reader role_key
  end

  # Instances of a defined subclass of Context are initialized checking first that all subclass defined roles
  # are provided in the creation invocation raising an error if any of them is missing.
  # Once the previous check is met, every object playing in the context instance is associated to the stated role.
  def initialize(players={})
    check_all_roles_provided_in(players)
    assign_roles_to_players(players)
  end


  private

    # Checks there is an intented player for every role.
    # Raises and error message in case of missing roles.
    def check_all_roles_provided_in(players={})
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
    #   - The object to play the role extends the defined module for that role, so it now respond to the methods
    #       defined in the role definition.
    #   - The object to play the role has access to the context it is playing.
    #   - The object to play the role has access to the rest of players in its context.
    #   - The context instance has access to this new player through a new instance variable defined with the name of the role.
    def assign_role_to_player(role_key, player)
      role_module     = roles[role_key]
      other_role_keys = roles.keys - [role_key]
      player.extend(role_module, Forwardable)
      player.instance_exec(self, other_role_keys) do |context, other_role_meths|
        define_singleton_method(:context) {context}
        def_delegators(:context, *other_role_meths)
      end
      instance_variable_set(:"@#{role_key}", player)
    end
end
