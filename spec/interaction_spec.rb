require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Interaction' do

  context "Inside a contextmethod(interaction)" do
    before(:all) do
      class AnotherContext < Context
        role :role1 do
        end
        role :role2 do
        end

        def interaction1
          role1
        end
      end
      @player1, @player2 = Object.new, Object.new
      @example_context = AnotherContext.new(:role1 => @player1, :role2 => @player2)
    end

    it("The developer has access to all the roleplayers...") {@example_context.interaction1.should be(@player1)}
    it("...named after the rolenames.") {@example_context.methods.should include('role1', 'role2')}
  end


end
