class Reporting::BrokerInvoicing

  def get_period_invoicing(from, to)

    file_name = "export/broker_invoicing_export_#{Time.now}.csv"
    # report = File.generate(file_name,"")
    CSV.open(file_name, "a") do |csv|
      csv << ["Agence", "Status","Leads période", "Leads DD ", "Leads SL"]
    end

    BrokerAgency.selectable_agencies.each do |ba|
      item = []
      item.push(ba.name)
      item.push(ba.status)
      inscope_subs = ba.get_subscribers(from, to)
      item.push(inscope_subs.count)
      item.push(inscope_subs.select{|s| s.is_ding_dong_user?}.count)
      item.push(inscope_subs.select{|s| !s.is_ding_dong_user?}.count)

      CSV.open(file_name, "a") do |csv|
        csv << item
      end
    end
  end
end