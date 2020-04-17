class String

  ## CHARACTER METHODS

  def transform_litteral_numbers
    return self.downcase.gsub(" un ", " 1 ").gsub(" une ", " 1 ").gsub(" deux ", " 2 ").gsub(" trois ", " 3 ").gsub(" quatre ", " 4 ").gsub(" cinq ", " 5 ").gsub(" six ", " 6 ").gsub(" sept ", " 7 ").gsub(" huit ", " 8 ").gsub(" neuf ", " 9 ")
  end

  def clean_img_link_https
    "https:" + self if self[0..1] == "//"
  end

  def to_int_scrp
    self.tr("^0-9", "").to_i
  end

  def to_float_to_int_scrp
    self.tr(",", ".").to_f.round.to_i
  end

  def specific_trim_scrp(trim)
    self.tr(trim, "")
  end

  def specific_substract_scrp(subs)
    self.tr(subs, "")
  end

  def remove_acc_scrp
    return self.tr(
             "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž-",
             "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz "
           ).gsub("saint", "st").gsub("sainte", "ste").downcase
  end

  def convert_numerals_scrp
    regex = "(premier|deuxieme|troisieme|quatrieme|cinquieme|sixieme|septieme|huitieme|neuvieme|dixieme)"
    numeral = self.match(/#{regex}/i).to_s
    case numeral
    when "premier"
      return self.gsub(/#{regex}/i, "1er")
    when "deuxieme"
      return self.gsub(/#{regex}/i, "2eme")
    when "troisieme"
      return self.gsub(/#{regex}/i, "3eme")
    when "quatrieme"
      return self.gsub(/#{regex}/i, "4eme")
    when "cinquieme"
      return self.gsub(/#{regex}/i, "5eme")
    when "sixieme"
      return self.gsub(/#{regex}/i, "6eme")
    when "septieme"
      return self.gsub(/#{regex}/i, "7eme")
    when "huitieme"
      return self.gsub(/#{regex}/i, "8eme")
    when "neuvieme"
      return self.gsub(/#{regex}/i, "9eme")
    when "dixieme"
      return self.gsub(/#{regex}/i, "10eme")
    else
      return self
    end
  end

  def floors_str_scrp
    regex_floors = '((\d+(er|(e|è|é)me|e|°)|premier)(.)((e|é|è)tage|et dernier etage)|rez-de-chauss(e|è|é)e|rez de chauss(e|è|é)e)'
    has_floor = self.match(/#{regex_floors}/i)
    has_floor.is_a?(MatchData) ? floor_number = self.match(/#{regex_floors}/i).to_s.gsub(" et dernier", "").capitalize : floor_number = nil
    return floor_number
  end

  def elevator_str_scrp
    regex_lift = "(avec ascenseur|par ascenseur)"
    has_a_lift = self.match(/#{regex_lift}/i)
    regex_no_lift = "(sans ascenseur)"
    has_no_lift = self.match(/#{regex_no_lift}/i)
    if has_a_lift.is_a?(MatchData)
      lift = true
    elsif has_no_lift.is_a?(MatchData)
      lift = false
    else
      lift = nil
    end
    return lift
  end

  def district_regex_scrp
    area_regex = '(?<=paris )(.*?)(\d+)(.?)(er|e|)|(?<=paris )(.?)(M{0,3}(?:C[MD]|D?C{0,3})(?:X[CL]|L?X{0,3})(?:I[XV]|V?I{0,3}))|(\d+)(.?)(er|eme|e)(.?)(arr)'
    area = self.match(/#{area_regex}/i).to_s
    case area.gsub("arr", "").tr(" ", "")
    when "1er", "1e", "i", "1", "01", "01e"
      return "1"
    when "2eme", "2e", "ii", "2", "02", "02e", "02è"
      return "2"
    when "3eme", "3e", "iii", "3", "03", "03e", "03è"
      return "3"
    when "4eme", "4e", "iv", "4", "04", "04e", "04è"
      return "4"
    when "5eme", "5e", "v", "5", "05", "05e", "05è"
      return "5"
    when "6eme", "6e", "vi", "6", "06", "06e", "06è"
      return "6"
    when "7eme", "7e", "vii", "7", "07", "07e", "07è"
      return "7"
    when "8eme", "8e", "viii", "8", "08", "08e", "08è"
      return "8"
    when "9eme", "9e", "ix", "9", "09", "09e", "09è"
      return "9"
    when "10eme", "10e", "x", "10"
      return "10"
    when "11eme", "11e", "xi", "11"
      return "11"
    when "12eme", "12e", "xii", "12"
      return "12"
    when "13eme", "13e", "xiii", "13"
      return "13"
    when "14eme", "14e", "xiv", "14"
      return "14"
    when "15eme", "15e", "xv", "15"
      return "15"
    when "16eme", "16e", "xvi", "16"
      return "16"
    when "17eme", "17e", "xvii", "17"
      return "17"
    when "18eme", "18e", "xviii", "18"
      return "18"
    when "19eme", "19e", "xix", "19"
      return "19"
    when "20eme", "20e", "xx", "20"
      return "20"
    else
      return "N/C"
    end
  end

  def district_generator_scrp
    if self.length == 2
      return "750#{self}"
    elsif self.length == 1
      return "7500#{self}"
    else
      return "N/C"
    end
  end

  ############################################
  ## STRING METHODS FOR SELOGER WEIRD JSON ##
  ############################################
  def decode_json_scrp
    self
      .gsub('\u0022', '"')
      .gsub('\u00E0', "à")
      .gsub('\u00E2', "â")
      .gsub('\u00E8', "è")
      .gsub('\u00E9', "é")
      .gsub('\u00E7', "ç")
      .gsub('\u00F9', "ù")
      .gsub('\u0026', "&")
      .gsub('\u20AC', "€")
      .gsub('\u0027', "'")
      .gsub('\u00A0', "")
      .gsub('\u00C8', "È")
      .gsub('\u00B2', "²")
      .gsub('\u00C9', "É")
      .gsub('\\"', '"')
  end

  ##############################
  ## METHODS FOR PHONE NUMBER ##
  ##############################

  def convert_phone_nbr_scrp
    if self[0] == "0"
      self[0].gsub("0", "+33") + self[1..-1]
    end
  end

  def sl_phone_number_scrp
    self.tr!("\s", "")
    unless self == "N/C"
      if self.include?("/")
        second_nbr = self.split("/")[1]
        second_nbr.convert_phone_nbr_scrp
      else
        self.convert_phone_nbr_scrp
      end
    end
  end
end
