class Reporting::BrokerInvoicing

  def get_period_invoicing(from, to)

    file_name = "export/broker_invoicing_export_#{Time.now}.csv"
    # report = File.generate(file_name,"")
    CSV.open(file_name, "a") do |csv|
      csv << ["Agence", "Status","Leads période", "Leads DD ", "Leads SL"]
    end

    BrokerAgency.where(status: ["test", "premium"]).where.not(name: "Ding Dong Courtage").each do |ba|
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

  def monthly_reset
    BrokerAgency.where(status: ["premium", "test"]).each do |ba|

      current_period_provided_leads = ba.get_subscribers(Date.today.at_beginning_of_month, Date.today.at_end_of_month).count
      current_period_leads_left = ba.max_period_leads - current_period_provided_leads

      ba.update(
        current_period_leads_left: current_period_leads_left,
        current_period_provided_leads: current_period_provided_leads
      )

    end
  end

end