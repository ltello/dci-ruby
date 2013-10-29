require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Interaction:' do

  context "Inside a Context instance method(interaction)..." do
    before(:all) do
      class TestingInteractionsContext < DCI::Context
        role :role1 do
        end
        role :role2 do
        end

        def interaction1
          role1
        end
      end
      @player1, @player2 = Object.new, Object.new
      @test_interactions_context = TestingInteractionsContext.new(:role1 => @player1, :role2 => @player2, :setting1 => :one)
    end

    it("...the developer has access to all the roleplayers...") do
      @test_interactions_context.interaction1.should be_a(TestingInteractionsContext::Role1)
      @test_interactions_context.send(:role2).should be_a(TestingInteractionsContext::Role2)
    end
    it("...via private instance methods named after their role keys.") do
      @test_interactions_context.private_methods(false).should include('role1', 'role2')
    end

    it("He also have private access to extra args received in the instantiation of its context...") do
      @test_interactions_context.private_methods.should include('settings')
    end
    it("...calling #settings(key)") do
      @test_interactions_context.send(:settings, :setting1).should be(:one)
    end
  end

end
