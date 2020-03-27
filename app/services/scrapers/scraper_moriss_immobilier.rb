class ScraperMorissImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args, :http_request

  def initialize
    @url = "https://www.morissimmobilier.com/wp-admin/admin-ajax.php"
    @source = "MorissImmobilier"
    @main_page_cls = "div.property_listing"
    @type = "HTTPRequest"
    @waiting_cls = "carousel-inner"
    @multi_page = false
    @page_nbr = 1
    @wait = 0
    @click_args = [{ element: "div", values: { id: "a_filter_order" } }, { element: "li", values: { text: "Le plus récent d'abord" } }]
    @properties = []
    @http_request = [{}, { "action" => "wpestate_advanced_search_filters", "args" => '{ "cache_results": false, "update_post_meta_cache": false, "update_post_term_cache": false, "post_type": "estate_property", "post_status": "publish", "paged": 1, "posts_per_page": 70, "meta_key": "prop_featured", "orderby": "meta_value", "order": "DESC", "meta_query": "", "tax_query": { "relation": "AND", "0": "", "1": "", "2": "", "3": "", "4": "" }, "post__in": ["41342", "45220", "43149", "45491", "43494", "45233", "47186", "44942", "40133", "42666", "46986", "46999", "42327", "45941", "45541", "39506", "47276", "29615", "47187", "45432", "47189", "45556", "46911", "29750", "40204", "47252", "46962", "42098", "46416", "44281", "42231", "46422", "46926", "45755", "46435", "46720", "45604", "43865", "42276", "44113", "42843", "37218", "42389", "32389", "32402", "32458", "42346", "47148", "41142", "42109", "32466", "40967", "44709", "33172", "35836", "34271", "47156", "38290", "36296", "34414", "47089", "32508", "44125", "43669", "32658", "35618", "38811", "44560", "32688", "38751", "41629", "36981", "32814", "46342", "47097", "32825", "45917", "35847", "45485", "45151", "32862", "46327", "37135", "32865", "35351", "39002", "33330", "32891", "43831", "42966", "32916", "42541", "47223", "30908", "40319", "38669", "42072", "34348", "30924", "34964", "42373", "45763", "42490", "34564", "33845", "39632", "30950", "34406", "36256", "41026", "34436", "39640", "47117", "45842", "47039", "39530", "43456", "33962", "36789", "44946", "36342", "46066", "35874", "31175", "45498", "45610", "43469", "31241", "40333", "37019", "37231", "46772", "44959", "36206", "41721", "42707", "46617", "42967", "35064", "46940", "37386", "42764", "31305", "46406", "41103", "44722", "44776", "31334", "36760", "44976", "31347", "46828", "31368", "44833", "47106", "44682", "47168", "46167", "46540", "46638", "41885", "47048", "31416", "33463", "31448", "46328", "41037", "31491", "40190", "35950", "38909", "41703", "46691", "46929", "43649", "31774", "31776", "47050", "31806", "43175", "31823", "44528", "31836", "45818", "39372", "46852", "43955", "44461", "40983", "43182", "31862", "43190", "46942", "45828", "38236", "43201", "31888", "43209", "31905", "31908", "43221", "31910", "39460", "47058", "43232", "31919", "43238", "31932", "43244", "35905", "43253", "41038", "45069", "37562", "43261", "39470", "31955", "43896", "45734", "32023", "43270", "40523", "46282", "32049", "32057", "43278", "43281", "46551", "43291", "35153", "43302", "41423", "46955", "39421", "42207", "38650", "44462", "32069", "32076", "32088", "39478", "42220", "41053", "32096", "46562", "32108", "32119", "32125", "32136", "39440", "32165", "41814", "41325", "36394", "32173", "32189", "39480", "45848", "32196", "43692", "39859", "39487", "32212", "32214", "32224", "45430", "33409", "32271", "35161", "32281", "32292", "32308", "39930", "32328", "32347", "34798", "38790", "38689", "32370", "41272", "33384", "39867", "39072", "39495", "47313", "29825", "29837", "36132", "29851", "45661", "41255", "40094", "35915", "46450", "37726", "29891", "41532", "46906", "35308", "35236", "46507", "30036", "44302", "37590", "34284", "30149", "36171", "46490", "30207", "41195", "39918", "46574", "30247", "37544", "37455", "30303", "44308", "44252", "30344", "39033", "30370", "37672", "37828", "46647", "33881", "34528", "34571", "47125", "36827", "46079", "46868", "30411", "30425", "30437", "38596", "30471", "30504", "30515", "47138", "46588", "46814", "30530", "45664", "30542", "30580", "46590", "44864", "30616", "46881", "30629", "34584", "30661", "30674", "35170", "44175", "33723", "33495", "30709", "30719", "30721", "30733", "30755", "46049", "34309", "45175", "39603", "30774", "30780", "30788", "30809", "30838", "47080", "30851", "35639", "37839", "30863", "30866", "42179", "30881"] }', "value" => "3", "page_id" => "5" }]
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      if access_xml_text(item, "div.ribbon-inside") == "Disponible"
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "div.item > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.infosize_unit_type4 > span"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = regex_gen(access_xml_text(item, "div.property_address_type4 > span > a"), '(\d+){2}').district_generator
          hashed_property[:rooms_number] = access_xml_text(item, "div.inforoom_unit_type4 > span").to_int_scrp
          hashed_property[:price] = access_xml_text(item, "div.listing_unit_price_wrapper").to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h4 > a"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if is_property_clean(hashed_property) && !hashed_property[:area].nil?
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.wpestate_property_description > p").specific_trim_scrp("\n").strip
            hashed_property[:agency_name] = access_xml_text(html, "div.agent_unit > div > h4 > a")
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.gallery_wrapper > div", "style")
            hashed_property[:images].each do |image_url|
              image_url.gsub!("background-image:url(", "").gsub!(")", "")
            end
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert_v2(hashed_property)
            i += 1
            break if i == limit
          end
        rescue StandardError => e
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          puts e.message
          puts e.backtrace
          next
        end
      end
    end
    return @properties
  end
end
