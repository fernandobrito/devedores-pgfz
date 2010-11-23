def show_captcha(b)
  raise "Please install jp2a in order to convert CAPTCHA image to ASCII" if `which jp2a` == ""

  b.image(:id, "listaDevedoresForm:captchaImage").save("/tmp/captcha.jpg")
  puts `jp2a /tmp/captcha.jpg -i --colors`

  `convert /tmp/captcha.jpg /tmp/captcha.pnm`
  print "GOCR: " + `gocr -C A-Z -a 90 /tmp/captcha.pnm` if `which gocr` != ""
  print "OCRad: " + `ocrad -e letters_only -c ascii -l 2 /tmp/captcha.pnm`.sub("\n","") if `which ocrad` != ""
end


def get_current_page(b)
  output = i = 0

  while(output==0)
    sleep(0.1) until b.td(:class, "dr-dscr-act rich-datascr-act").exists or b.td(:class, "dr-dscr-act rich-datascr-act ").exists

    # output = b.td(:class, "dr-dscr-act rich-datascr-act").text.to_i if b.td(:class, "dr-dscr-act rich-datascr-act").exists
    output = b.td(:class, "dr-dscr-act rich-datascr-act").html.gsub(/<td\b[^>]*>(.*?)/, "").to_i if b.td(:class, "dr-dscr-act rich-datascr-act").exists
    output = b.td(:class, "dr-dscr-act rich-datascr-act ").text.to_i if b.td(:class, "dr-dscr-act rich-datascr-act ").exists

    # puts "dentro do loop de get_current_page"

    i += 1
    raise "Timeout" if i == 40
  end

   return output
end


def get_total_pages(b)
  return b.div(:id, "listaDevedoresForm:listaDevedores").text.split("\n")[0].gsub(/[^0-9]/, "").strip.to_i / 20
end


def go_to_page(b, page)
  start_from_behind = false

  total_pages = get_total_pages(b)

  if page > (total_pages) / 2
    start_from_behind = true
    b.refresh
    sleep(1)
    b.refresh
    b.div(:class, "arrow-last").click
    b.refresh
    sleep(1)
    b.refresh
  end

  puts "Indo para a página: #{page}" if DEBUG

  puts "31" if DEBUG
  current_page = get_current_page(b)
  puts "32" if DEBUG

  while(current_page != page) do
    puts "Página Atual: #{current_page} -- Faltam: #{page - current_page}" if DEBUG

    puts "11" if DEBUG
    sleep(0.1) until b.tables[5].exists and b.tables[5].rows[0].exists and b.tables[5].rows[0].tds[12].exists
    puts "12" if DEBUG

    if start_from_behind

      if (current_page - page) > 4
        b.tables[5].rows[0].tds[3].click # this is the first page button we can see
      else
        b.div(:class, "arrow-previous").click
      end

    else

      if (page - current_page) > 3
        b.tables[5].rows[0].tds[12].click # this is the last page button we can see
      else
        b.div(:class, "arrow-next").click
      end

    end

    puts "1" if DEBUG
    sleep(0.1) until b.td(:class, "dr-dscr-act rich-datascr-act").exists or b.td(:class, "dr-dscr-act rich-datascr-act ").exists
    puts "2" if DEBUG

    puts "21" if DEBUG
    sleep(0.1) until b.tables[5].exists and sleep(0.1) and b.tables[5].rows[0].exists and b.tables[5].rows[0].tds[12].exists
    puts "22" if DEBUG

    b.refresh
    puts "3" if DEBUG

    current_page = get_current_page(b)
    puts "4" if DEBUG

  end

  return b
end

