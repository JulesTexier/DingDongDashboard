class Api::V1::WebhooksController < ApplicationController
  protect_from_forgery with: :null_session

  include ActionController::HttpAuthentication::Token::ControllerMethods

  def handle_postmark_inbound
    if params["FromName"] == "SeLoger"
      if params["Subject"].match(/(\d){1,}(\s)(annonce)/i).is_a?(MatchData)
        Email::ScraperSeLogerMultiple.new(params["HtmlBody"]).launch
      else
        Email::ScraperSeLogerSingle.new(params["HtmlBody"]).launch
      end
      # Gérer des condtitions pour savoir si on a bien inséré la property ou pas ... (doublon, 500 ou succès)
      render json: { status: "SUCCESS", message: "Mail from SeLoger", data: nil }, status: 200
    elsif params["FromName"] == "Postmarkapp Support"
      render json: { status: "SUCCESS", message: "Mail from PostMark Support", data: nil }, status: 200
    else
      render json: { status: "ERROR", message: "Can't handle this email" }, status: 500
    end
  end

  def handle_postmark_growth_emailing
    tag = params["Tag"] #IMPORTANT : ALL EMAILS IN MAILER MUST HAVE A TAG
    step = Step.find_by(tag: tag)

    # Only when tag is corresponding to a step
    if !step.nil?
      s = subscriber.find_by(email: params["Recipient"])
      if !s.nil?
        s.update(status: step.subscriber_status)
      end
    end
  end

  def handle_postmark_new_contact
    ge = GrowthEngine.new
    ge.perform_email_webhook(request.body.string)
  end

  def handle_website_link_clicked
    unless params["id"].nil? || params["ss"].nil?
      subscriber = Subscriber.find(params["id"])
      ss = SequenceStep.find(params["ss"])
      status_name = ss.get_status_name + "_website_clicked"
      status = Status.find_by(name: status_name)
      status = Status.create(name: status_name, description: "[[WEBSITE_CLICKED]] - " + ss.description.to_s, status_type: "acquisition") if status.nil?
      SubscriberStatus.create(subscriber: subscriber, status: status)
    end
  end

  def handle_form_link_clicked
    unless params["id"].nil? || params["ss"].nil?
      subscriber = Subscriber.find(params["id"])
      ss = SequenceStep.find(params["ss"])
      status_name = ss.get_status_name + "_form_clicked"
      status = Status.find_by(name: status_name)
      status = Status.create(name: status_name, description: "[[FORM_CLICKED]] - " + ss.description.to_s, status_type: "acquisition") if status.nil?
      SubscriberStatus.create(subscriber: subscriber, status: status)
    end
  end
end
