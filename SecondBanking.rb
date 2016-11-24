require 'watir-webdriver'

Selenium::WebDriver::Chrome.driver_path= "/home/koss/Documents/CpRuby/OB/chromedriver"

WEB = Watir::Browser.new :chrome

class Accounts
    def initialize(user)
        @user = user

    end

    @accounts = []

    @@current_account = {}
    def getAll
        waiting(WEB.div(:class, 'contract status-active'))
        acc_list = WEB.divs(:class, 'contract status-active').length.to_i

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


    def selected
        puts "Select Account to access"

        @selected_account = gets.chomp!
        WEB.as(:class, 'name').each do |n|
            waiting(n).click if n.text == @selected_account
        end
        @@current_account = {:"Name" => WEB.a(:class, 'title').text ,
            :"Balance" => WEB.span(:class, 'amount').text ,
        :"Currency" => WEB.span(:class, 'amount currency').text}
    end

end

class Transactions < Accounts
    def initialize(month, day)
        @month = month
        @day = day
    end
    @@transactions_array = []
    def from_date
        if @month != "No Month" then
            waiting(WEB.input(:name, 'from')).click  #Opening "from date" calendar popup

            #Searching through calendar month till find the one we need
            while @month.capitalize != waiting(WEB.span(:class, 'ui-datepicker-month')).text do
                waiting(WEB.a(:class, 'ui-datepicker-prev ui-corner-all')).click
            end
            #Selecting day
            waiting(WEB.link(:text, @day)).click
        end

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

    end
    def output
        @@current_account[:"Transactions"] = @@transactions_array
        puts @@current_account
    end
end

def waiting(x)
    Watir::Wait.until {x.exists?}
    return x
end

def load_login_page
    WEB.goto "https://wb.micb.md/way4u-wb2/#login"
end

def change_language_to_en
    waiting(WEB.li(:class, 'language-item en')).click
end

def login_gets
    puts "User name"
    user_name = gets.chomp!
    puts "Password"
    user_pass = gets.chomp!

    waiting(WEB.text_field(:name, 'login')).set(user_name)
    waiting(WEB.text_field(:name, 'password')).set(user_pass)

    waiting(WEB.button(type: 'submit')).click

end

def select_account
    newuser = Accounts.new(waiting(WEB.span(:class, "user-name")).text)
    newuser.getAll
    newuser.selected
end

def to_transactions
    waiting(WEB.element(id: 'ui-id-3')).click #To transaction history
end

def get_transactions
    to_transactions

    puts "If you have a prefered 'from' date, type a month from which you want to see your transactions"
    puts "If you just want to see last few, type 'Last' "

    month = gets.chomp!

    if month != 'Last' then
        month.capitalize!
        puts "Select a Day"
        day = gets.chomp!
    else
        month = "No Month"
        day = "No Day"
    end

    @request = Transactions.new(month, day)
    @request.from_date

end

load_login_page
change_language_to_en
login_gets


select_account
get_transactions
@request.output
