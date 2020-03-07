class String

  ## CHARACTER METHODS
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
    self.tr!(
      "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž-",
      "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz "
    )
    self.gsub!("saint", "st")
    self.gsub!("sainte", "ste")
    self.downcase!
    return self
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
    regex_lift = "(avec ascenseur|sans ascenseur)"
    has_a_lift = self.match(/#{regex_lift}/i)
    has_a_lift.is_a?(MatchData) ? lift = true : lift = false
    return lift
  end

  ################################################
  ## TRANSLATE AREA, MAINLY FOR MEILLEURSAGENTS ##
  ################################################
  def area_translator_scrp
    area_regex = '(\d+)*(er|(è|e)me)'
    area = self.match(/#{area_regex}/i).to_s
    case area
    when "1er"
      return "75001"
    when "2ème"
      return "75002"
    when "3ème"
      return "75003"
    when "4ème"
      return "75004"
    when "5ème"
      return "75005"
    when "6ème"
      return "75006"
    when "7ème"
      return "75007"
    when "8ème"
      return "75008"
    when "9ème"
      return "75009"
    when "10ème"
      return "75010"
    when "11ème"
      return "75011"
    when "12ème"
      return "75012"
    when "13ème"
      return "75013"
    when "14ème"
      return "75014"
    when "15ème"
      return "75015"
    when "16ème"
      return "75016"
    when "17ème"
      return "75017"
    when "18ème"
      return "75018"
    when "19ème"
      return "75019"
    when "20ème"
      return "75020"
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
