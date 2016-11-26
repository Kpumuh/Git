require 'watir-webdriver'
require 'json'

Selenium::WebDriver::Chrome.driver_path= "/home/koss/Documents/CpRuby/OB/chromedriver"

WEB = Watir::Browser.new :chrome

class Accounts
    def initialize(account, balance, currency)
        @account = account
        @balance = balance
        @currency = currency
    end
    @@myAcc = {}
    def my_account
        @@myAcc = {:"Account" => @account,
            :"Balance" => @balance,
        :"Currency" => @currency}
        return @@myAcc
    end
end

class Transactions
    def initialize(trans_hash)
        @trans_hash = trans_hash
    end
    @@myTransactions = {}
    def my_transactions
        @@myTransactions = {:"Transactions" => @trans_hash}
        return @@myTransactions
    end

end

class Autorization
    def initialize(user_name, user_pass)
        @user_name = user_name
        @user_pass = user_pass
    end

    def login_in
        WEB.goto "https://wb.micb.md/way4u-wb2/#login"

        waiting(WEB.li(:class, 'language-item en')).click

        waiting(WEB.text_field(:name, 'login')).set(@user_name)
        waiting(WEB.text_field(:name, 'password')).set(@user_pass)

        waiting(WEB.button(type: 'submit')).click

    end

    @accounts = {}
    def show_accounts
        waiting(WEB.div(:class, 'contract status-active'))
        acc_list = WEB.divs(:class, 'contract status-active').length

        for i in 0..(acc_list - 1) do
            name = []
            balance = []

            WEB.as(:class, 'name').each {|n| name << n.text}
            WEB.divs(:class, 'balance').each {|n| balance << n.text}

            @accounts = {:"Account" => name.[](i),
            :"Balance" => balance.[](i)}

            puts @accounts

        end

    end

    def select_account
        puts "Select Account to access"

        @selected_account = "2259A09211581"#gets.chomp!
        WEB.as(:class, 'name').each do |n|
            waiting(n).click if n.text == @selected_account
        end

    end
    @@account_info = []
    def account_info(num)

        @@a = WEB.a(:class, 'title').text
        @@b = WEB.span(:class, 'amount').text
        @@c = WEB.span(:class, 'amount currency').text
        @@account_info = [@@a, @@b, @@c]
        return @@account_info[num]
    end
    @@transactions_array = []
    def get_from_date(month, day)
        @month = month
        @day = day


        waiting(WEB.input(:name, 'from')).click  #Opening "from date" calendar popup

        #Searching through calendar month till find the one we need
        while @month.capitalize != waiting(WEB.span(:class, 'ui-datepicker-month')).text do
            waiting(WEB.a(:class, 'ui-datepicker-prev ui-corner-all')).click
        end
        #Selecting day
        waiting(WEB.link(:text, @day)).click
    end
    def get_transactions
        waiting(WEB.element(id: 'ui-id-3')).click

        waiting(WEB.a(:class, 'operation-details'))
        WEB.elements(:class, 'operation-details').each do |n|

            waiting(n).click
            name = waiting(n).text #Operation name
            #First value from info popup is a transaction date
            #Last value from info popup - amount transfered
            waiting(WEB.div(:class, 'value'))


            first_value = WEB.divs(:class, 'value').first.text
            first_name = WEB.divs(:class, 'name').first.text
            last_value = WEB.elements(:class, 'value').last.text
            last_name = WEB.elements(:class, 'name').last.text

            #Preparing for the output

            name_value_pair = {
                first_name => first_value ,
                "Operation name" => name ,
            last_name => last_value }
            @@transactions_array << name_value_pair

            WEB.send_keys :escape #Closing popup window with detailed info

        end
        return @@transactions_array
    end


end

def waiting(x)
    Watir::Wait.until {x.exists?}
    return x
end


user = Autorization.new("UserName", "UserPass")
user.login_in
user.show_accounts
user.select_account

account = Accounts.new(user.account_info(0),user.account_info(1),user.account_info(2))
current_transactions = Transactions.new(user.get_transactions)
puts account.my_account.merge(current_transactions.my_transactions)
