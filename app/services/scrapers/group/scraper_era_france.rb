class Group::ScraperEraFrance < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :click_args, :wait, :http_request, :http_type

  def initialize
    @url = "https://www.erafrance.com/catalog/advanced_search_result_carto.php?action=update_search&ville=75&map_polygone=&latlngsearch=2.3318341000%2C48.8357218000&cfamille_id_search=CONTIENT&cfamille_id_type=TEXT&cfamille_id=1%2C2&cfamille_id_tmp=1&cfamille_id_tmp=2&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_28_tmp=Vente&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75&C_65_temp=75&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MIN=&30min=&C_30_MAX=&C_30_tmp=&C_65_modal=75&check_C_28=Vente&C_33_search=EGAL&C_33_type=NUMBER&C_33_MIN=&C_33=&C_38_search=EGAL&C_38_type=NUMBER&C_38_MIN=&C_38=&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MIN=&C_30_MAX=&30min=&30max=&C_34_search=COMPRIS&C_34_type=NUMBER&C_34_MIN=&C_34_MAX=&C_47_search=SUPERIEUR&C_47_type=NUMBER&C_46_search=SUPERIEUR&C_46_type=NUMBER&C_41_search=EGAL&C_41_type=NUMBER&C_50_search=SUPERIEUR&C_50_type=NUMBER&C_110_search=EGAL&C_110_type=NUMBER&C_1737_search=EGAL&C_1737_type=NUMBER&C_49_search=SUPERIEUR&C_49_type=NUMBER&C_48_search=SUPERIEUR&C_48_type=NUMBER&keywords="
    @source = "ERA France"
    @main_page_cls = "div.bien"
    @type = "HTTPRequest"
    @multi_page = false
    @page_nbr = 1
    @wait = 0
    @properties = []
    @http_request = [{}, "jquery_aa_afunc=call&remote_function=get_products_search_ajax_perso&params%5B0%5D%5Baction%5D=update_search&params%5B0%5D%5Bmap_polygone%5D=2.40755166334373%2C48.85995730851735%2F2.40755166334373%2C48.81148410187589%2F2.2561165366569065%2C48.81148410187589%2F2.2561165366569065%2C48.85995730851735&params%5B0%5D%5Bpage%5D=1&params%5B0%5D%5Bsort%5D=PRODUCT_LIST_DATEd&params%5B0%5D%5Bsort_liste%5D=PRODUCT_LIST_DATEd&params%5B0%5D%5BC_28_search%5D=EGAL&params%5B0%5D%5BC_28_type%5D=UNIQUE&params%5B0%5D%5BC_28%5D=Vente&params%5B0%5D%5Bkeywords%5D=&params%5B0%5D%5Bcfamille_id_search%5D=EGAL&params%5B0%5D%5Bcfamille_id_type%5D=TEXT&params%5B0%5D%5Bcfamille_id%5D=1%2C2&params%5B0%5D%5BC_65_search%5D=CONTIENT&params%5B0%5D%5BC_65_type%5D=TEXT&params%5B0%5D%5BC_65%5D=75&params%5B0%5D%5BC_30_search%5D=COMPRIS&params%5B0%5D%5BC_30_type%5D=NUMBER&params%5B0%5D%5BC_30_MIN%5D=&params%5B0%5D%5BC_30_MAX%5D=&params%5B0%5D%5BC_47_search%5D=SUPERIEUR&params%5B0%5D%5BC_47_type%5D=NUMBER&params%5B0%5D%5BC_47%5D=&params%5B0%5D%5BC_46_search%5D=SUPERIEUR&params%5B0%5D%5BC_46_type%5D=NUMBER&params%5B0%5D%5BC_46%5D=&params%5B0%5D%5BC_41_search%5D=SUPERIEUR&params%5B0%5D%5BC_41_type%5D=NUMBER&params%5B0%5D%5BC_41%5D=&params%5B0%5D%5BC_50_search%5D=SUPERIEUR&params%5B0%5D%5BC_50_type%5D=NUMBER&params%5B0%5D%5BC_50%5D=&params%5B0%5D%5BC_110_search%5D=EGAL&params%5B0%5D%5BC_110_type%5D=FLAG&params%5B0%5D%5BC_110%5D=&params%5B0%5D%5BC_1737_search%5D=EGAL&params%5B0%5D%5BC_1737_type%5D=FLAG&params%5B0%5D%5BC_1737%5D=&params%5B0%5D%5BC_49_search%5D=SUPERIEUR&params%5B0%5D%5BC_49_type%5D=NUMBER&params%5B0%5D%5BC_49%5D=&params%5B0%5D%5BC_48_search%5D=SUPERIEUR&params%5B0%5D%5BC_48_type%5D=NUMBER&params%5B0%5D%5BC_48%5D=&params%5B0%5D%5BC_34_search%5D=COMPRIS&params%5B0%5D%5BC_34_type%5D=NUMBER&params%5B0%5D%5BC_34_MIN%5D=&params%5B0%5D%5BC_34_MAX%5D=&params%5B0%5D%5BC_33_search%5D=COMPRIS&params%5B0%5D%5BC_33_type%5D=NUMBER&params%5B0%5D%5BC_33_MIN%5D=&params%5B%5D=pagination&params%5B%5D=400&params%5B%5D=map_carto&params%5B%5D=images%2Fmarker_2017.png&params%5B%5D=&params%5B%5D=images%2Fmarker_2017.png&params%5B%5D=false&params%5B%5D=images%2Fmarker_2017.png"]
    @http_type = "post"
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.erafrance.com" + access_xml_link(item, "a", "href")[0].to_s.gsub("..", "")
        hashed_property[:surface] = access_xml_text(item, "div.bien_infos > p").to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.prix"), '(\d+)(.?)(\d+)(.?)(\d+)(...)dont').tr("^0-9", "") != "" ? regex_gen(access_xml_text(item, "div.prix"), '(\d+)(.?)(\d+)(.?)(\d+)(...)dont').tr("^0-9", "").to_float_to_int_scrp : access_xml_text(item, "div.prix").tr("^0-9", "").to_float_to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".bien_type"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.description.principale").tr("\n\t", "").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(html, "h2.titre_bien"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
          hashed_property[:agency_name] = access_xml_text(html, ".contact_agence_details > a > h3").tr("\n\r\t", "")
          agency_area = perform_district_regex(access_xml_text(html, "p.contact_agence_ville"))
          desc_area = perform_district_regex(hashed_property[:description])
          desc_area != agency_area && desc_area != "N/C" ? hashed_property[:area] = desc_area : hashed_property[:area] = agency_area
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "ul.slides > li > a", "href")
          hashed_property[:images].collect! { |img| "https://www.erafrance.com" + img.gsub("..", "") }
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
