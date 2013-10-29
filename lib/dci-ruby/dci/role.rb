module DCI

  class Role

    class << self

      # Make this class abstract: will not allow create instances.
      def new(*args, &block)
        raise 'This class is meant to be abstract and not instantiable' if self == DCI::Role
        super
      end

    end

    # Opts:
    #  player         => the object to adquire this role,
    #  context        => the context instance in which this role instance will play
    #  role_mate_keys => list of keys of the rest of roles playing in the given context
    def initialize(opts={})
      @player  = opts[:player]
      @context = opts[:context]
      define_role_mate_methods!(opts[:role_mate_keys])
    end


    private

      # Make the original object playing the role accessible only inside role definition code!
      def player
        @player
      end

      # For each role in the context, define a method so inside a role you can access all the others.
      def define_role_mate_methods!(role_mate_keys)
        self.class.class_exec(role_mate_keys) do |other_role_keys|
          other_role_keys.each do |role_key|
            if not private_method_defined?(role_key)
              define_method(role_key) do
                @context.send(role_key)
              end
              private role_key
            end
          end
        end
      end

  end

end
