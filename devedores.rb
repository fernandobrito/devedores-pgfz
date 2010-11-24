require "rubygems"
require "celerity"
require "funcoes"

DEBUG = true

# Starts
b = Celerity::Browser.new

# Read args
letter_to_go = ARGV.shift
page_to_go = ARGV.shift.to_i
save = ARGV.shift || "true"


while(true)
  b.goto "http://www2.pgfn.fazenda.gov.br/ecac/contribuinte/devedores/listaDevedores.jsf"

  show_captcha(b)

  # Read input
  print "==> Digite o que você viu: "
  captcha_answer = gets.chomp

  # Fill field and click in the letter
  b.text_field(:id, "listaDevedoresForm:captcha").value = captcha_answer
  b.link(:text, letter_to_go).click

  # Check if we are where we want
  break if b.html.include?("Foram encontrados")
end


puts "=> Passamos do CAPTCHA!" if DEBUG

# If we have to go somewhere, lets go!
if page_to_go != 1
  b = go_to_page(b, page_to_go)
end

current_page = get_current_page(b)
total_pages = get_total_pages(b)

puts "=> Estamos na página #{current_page} de #{total_pages}!" if DEBUG

while(!@stop) do
  current_page = get_current_page(b)

  puts "# pag: #{current_page} of #{total_pages} (#{sprintf("%.2f", current_page.to_f / total_pages * 100)}%) (#{letter_to_go})"

  if save == "true"
	  File.open(letter_to_go.downcase + ".csv", "a") do |f|
	    f.write "\n# pag: #{current_page}\n"
	    f.write b.tables[4].rows.collect{|a| a.text.split.join(" ").sub(" ",";")}[1..-1].join("\n")
	  end
  end

  b.div(:class, "arrow-next").click

  sleep(0.1) until (b.td(:class, "dr-dscr-act rich-datascr-act").exists or b.td(:class, "dr-dscr-act rich-datascr-act ").exists) \
                    and get_current_page(b) == current_page + 1

  b.refresh
end

