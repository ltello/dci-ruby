require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Context do

  context "Definition" do
    context "When Inherit from Context" do
      before(:all) do
        class ExampleContext < Context
          role :rolename do
          end

          def interaction1
          end
        end
      end

      it("A new context subclass is ready to be used...") {ExampleContext.superclass.should be(Context)}
      it("...in which the developer can define roles...") {ExampleContext.private_methods.should include("role")}
      it("...but privately inside the class.") {ExampleContext.should_not respond_to(:role)}
      it("He can also define contextmethods (instance methods) that acts as interactions.") {ExampleContext.public_instance_methods(false).should include('interaction1')}
    end
  end

  context "Use" do
    context "To use a Context" do
      before(:all) do
        class AnotherContext < Context
          role :role1 do
          end
          role :role2 do
          end

          def interaction1
            role1
          end

          def interaction2
            role1.object_id - role2.object_id
          end
        end
        @player1, @player2 = Object.new, Object.new
        @example_context   = AnotherContext.new(:role1 => @player1, :role2 => @player2)
      end

      it("You instanciate it...") {@example_context.class.should be(AnotherContext)}
      it("...providing a hash of type {:rolename1 => player1, ... }") do
        expect {AnotherContext.new(@player1, @player2)}.to raise_error
      end
      it("...with ALL rolenames as keys...") do
        expect {AnotherContext.new(:role1 => @player1)}.to raise_error('missing roles role2')
      end
      it("...and the objects to play those roles as values.") do
        [@player1, @player2].should include(@example_context.role1, @example_context.role2)
      end
      it("Once instanciated...") {@example_context.class.should be(AnotherContext)}
      it("...you call an interaction (instance method) on it") {@example_context.should respond_to(:interaction1)}
      it("...to start interaction among roleplayers inside the context") do
        @example_context.interaction2.should be_instance_of(Fixnum)
      end

    end
  end

end
