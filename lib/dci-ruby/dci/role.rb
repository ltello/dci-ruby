module DCI

  class Role

    class << self

      # Make this class abstract: will not allow create instances.
      def new(*args, &block)
        raise 'This class is meant to be abstract and not instantiable' if self == DCI::Role
        super
      end

      # Defines a new reader instance method for a context mate role, delegating it to the context object.
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
