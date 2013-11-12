require 'forwardable'

module DCI
  class Role
    extend ::Forwardable

    class << self

      # Make this class abstract: will not allow create instances.
      def new(*args, &block)
        raise 'This class is meant to be abstract and not instantiable' if self == DCI::Role
        super
      end

      # Defines a public instance_method named role_method_name delegating its behaviour to player#player_methodname
      # Ex: delegate_to_player :fullname, :name  #=> def name(*args, &block)
      #                                                player.send(:fullname, *args, &block)
      #                                              end
      def delegate_to_player(player_methodname, role_method_name = player_methodname)
        class_eval("def #{role_method_name}(*args, &block); player.send(:#{player_methodname}, *args, &block) end")
      end

      # Defines a private instance_method named role_method_name delegating its behaviour to player#player_methodname
      # Ex: delegate_to_player :fullname, :name  #=> def name(*args, &block)
      #                                                player.send(:fullname, *args, &block)
      #                                              end
      #                                              private :name
      def private_delegate_to_player(player_methodname, role_method_name = player_methodname)
        delegate_to_player(player_methodname, role_method_name)
        private role_method_name
      end

      # Defines multiple public instance_methods whose names are in the methodnames list
      # delegating their behaviour to their counterparts in player.
      # Ex: delegates_to_player :fullname, :age  #=> def fullname(*args, &block)
      #                                                player.send(:fullname, *args, &block)
      #                                              end
      #                                              def age(*args, &block)
      #                                                 player.send(:age, *args, &block)
      #                                              end
      def delegates_to_player(*methodnames)
        methodnames.each {|methodname| delegate_to_player(methodname)}
      end

      # Defines multiple private instance_methods whose names are in the methodnames list
      # delegating their behaviour to their counterparts in player.
      # Ex: private_delegates_to_player :fullname, :age  #=> def fullname(*args, &block)
      #                                                        player.send(:fullname, *args, &block)
      #                                                      end
      #                                                      def age(*args, &block)
      #                                                         player.send(:age, *args, &block)
      #                                                      end
      #                                                      private :fullname, :age
      def private_delegates_to_player(*methodnames)
        methodnames.each {|methodname| private_delegate_to_player(methodname)}
      end


      private

        # Defines a new private reader instance method for a context mate role, delegating it to the context object.
        def add_role_reader_for!(rolekey)
          return if private_method_defined?(rolekey)
          define_method(rolekey) {@context.send(rolekey)}
          private rolekey
        end

    end

    # Opts:
    #  player         => the object to adquire this role,
    #  context        => the context instance in which this role instance will play
    #  role_mate_keys => list of keys of the rest of roles playing in the given context
    def initialize(opts={})
      @player  = opts[:player]
      @context = opts[:context]
    end


    private

      # Make the original object playing the role accessible only inside role definition code!
      def player
        @player
      end

  end
end
