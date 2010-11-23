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

    output = b.td(:class, "dr-dscr-act rich-datascr-act").html.gsub(/<td\b[^>]*>(.*?)/, "").to_i if b.td(:class, "dr-dscr-act rich-datascr-act").exists
    output = b.td(:class, "dr-dscr-act rich-datascr-act ").text.to_i if b.td(:class, "dr-dscr-act rich-datascr-act ").exists

    i += 1
    raise "Timeout" if i == 40
  end

   return output
end


def get_total_pages(b)
  sleep(0.1) until b.div(:id, "listaDevedoresForm:listaDevedores").text.include?("Foram encontrados")
  return b.div(:id, "listaDevedoresForm:listaDevedores").text.split("\n")[0].gsub(/[^0-9]/, "").strip.to_i / 20
end


def go_to_page(b, page)
  b.execute_script("javascript:Event.fire(document.getElementById('listaDevedoresForm:j_id53_table').rows[0].cells[11], 'rich:datascroller:onscroll', {'page': '" + page.to_s + "'});")
  sleep(2)
  b.refresh

  return b
end

