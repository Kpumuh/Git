require 'watir-webdriver'
require 'json'

Selenium::WebDriver::Chrome.driver_path= "/home/koss/Documents/CpRuby/OB/chromedriver"

$b = Watir::Browser.new :chrome



$b.goto "https://wb.micb.md/way4u-wb2/#login"
$b.li(:class, 'language-item en').click
sleep 2


puts "Type a valid user name, then press enter."
$user_name = gets.chomp!

puts "Password please for #{$user_name} account"
user_pass = gets.chomp!


$b.text_field(name: 'login').set($user_name)
$b.text_field(name: 'password').set(user_pass)
sleep 1
$b.button(type: 'submit').click
sleep 5

number = "2259A09211581"   # Active account number

$b.a(:title, number).click #Selecting active account
sleep 2

$b.element(id: 'ui-id-2').click
sleep 2


class Transactions
    def initialize(month, day)
        @month = month
        @day = day

    end

    def fromDate
        $b.element(id: 'ui-id-3').click #To transaction history
        sleep 1
        $b.input(:name, 'from').click  #Opening "from date" calendar popup
        sleep 1

        #Searching through calendar month till find the one we need
        while @month.capitalize != $b.span(:class, 'ui-datepicker-month').text do
            $b.a(:class, 'ui-datepicker-prev ui-corner-all').click
            sleep 1
        end
        #Selecting day
        $b.link(:text, @day).when_present.click
        sleep 3

        transactions_array = []
        $account = $b.div(:class, "content-header editable").a(:href, '#').text

        $b.elements(:class, 'operation-details').each do |n|
            n.click
            sleep 1
            name = n.text #Operation name

            #First value from info popup is a transaction date
            #Last value from info popup - amount transfered
            first_value = $b.divs(:class, 'value').first.text
            first_name = $b.divs(:class, 'name').first.text
            last_value = $b.elements(:class, 'value').last.text
            last_name = $b.elements(:class, 'name').last.text

            $balance = $b.span(:class, 'amount').text
            $currency = $b.span(:class, 'amount currency USD').text



            #Preparing for the output
            name_value_pair = {
                :"#{first_name}" => first_value ,
                :"Operation name" => name ,
            :"#{last_name}" => last_value }
            transactions_array << name_value_pair

            sleep 1
            $b.send_keys :escape #Closing popup window with detailed info
            sleep 1

        end

        #Output
        n_hash = Hash["accounts" => [{ $user_name => $account ,
            "balance" => $balance ,
            "currency" => $currency ,
            "transactions" => transactions_array
        }]]


        File.open("Transactions.json", "w") do |f|
            f.print n_hash.to_json.gsub(",{", ",\n{")

        end
    end

end

newRequest = Transactions.new("September", "4")
newRequest.fromDate
