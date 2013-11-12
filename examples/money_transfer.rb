require 'dci-ruby'


class CheckingAccount
  attr_reader   :account_id
  attr_accessor :balance

  def initialize(account_id, initial_balance=0)
    @account_id, @balance = account_id, initial_balance
  end
end


class MoneyTransferContext < DCI::Context

  # Roles Definitions

    role :source_account do
      delegates_to_player :balance, :account_id
      private_delegate_to_player :balance=

      def run_transfer_of(amount)
        self.balance -= amount
        puts "\t\tAccount(\##{account_id}) sent #{amount}€ to Account(\##{target_account.account_id})."
      end
    end

    role :target_account do
      delegates_to_player :balance, :account_id
      private_delegate_to_player :balance=

      def run_transfer_of(amount)
        self.balance += amount
        puts "\t\tAccount(\##{account_id}) received #{amount}€ from Account(\##{source_account.account_id})."
      end
    end


  # Interactions

    def run(amount=settings(:amount))
      puts "\nMoney Transfer of #{amount}€ between Account(\##{source_account.account_id}) and Account(\##{target_account.account_id})"
      puts "\tBalances Before: #{balances}"
      source_account.run_transfer_of(amount)
      target_account.run_transfer_of(amount)
      puts "\tBalances After:  #{balances}"
    end


  private

    def accounts
      [source_account, target_account]
    end

    def balances
      accounts.map {|account| "#{account.balance}€"}.join(' - ')
    end
end

acc1 = CheckingAccount.new(1, 1000)
acc2 = CheckingAccount.new(2)

MoneyTransferContext.new(:source_account => acc1,
                         :target_account => acc2,
                         :amount         => 200).run
4.times do
  MoneyTransferContext.new(:source_account => acc1,
                           :target_account => acc2).run(200)
end
