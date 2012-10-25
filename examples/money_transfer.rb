require 'dci-ruby'


class CheckingAccount
  attr_reader   :account_id
  attr_accessor :balance

  def initialize(account_id)
    @account_id, @balance = account_id, 0
  end
end


class MoneyTransferContext < Context

  # Roles Definitions

    role :source_account do
      def run_transfer_of(amount)
        self.balance -= amount
        puts "Source Account #{account_id} sent $#{amount} to Target Account #{target_account.account_id}."
      end
    end

    role :target_account do
      def run_transfer_of(amount)
        self.balance += amount
        puts "Target Account #{account_id} received $#{amount} from Source Account #{source_account.account_id}."
      end
    end


  # Interactions

    def run
      puts "Balances Before: #{balances}"
      source_account.run_transfer_of(amount)
      target_account.run_transfer_of(amount)
      puts "Balances After:  #{balances}"
    end


  private

    def accounts
      [source_account, target_account]
    end

    def balances
      accounts.map {|account| "$#{account.balance}"}.join(' - ')
    end
end

MoneyTransferContext.new(:source_account => CheckingAccount.new(1),
                         :target_account => CheckingAccount.new(2),
                         :amount         => 500).run
