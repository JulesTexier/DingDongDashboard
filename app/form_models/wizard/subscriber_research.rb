module Wizard
  module SubscriberResearch
    STEPS = %w(step1 step2 step3).freeze

    class Base
      include ActiveModel::Model
      attr_accessor :subscriber_research, :subscriber

      delegate *::Research.attribute_names.map { |attr| [attr, "#{attr}="] }.flatten, to: :subscriber_research

      def initialize(subscriber_research_attributes)
        @subscriber_research = ::Research.new(subscriber_research_attributes)
        @subscriber = ::Subscriber.new
      end
    end

    class Step1 < Base
      validates :agglomeration, presence: true
    end
    
    class Step2 < Step1
      validates :min_surface, presence: true
      validates :max_price, presence: true
      validates :min_rooms_number, presence: true
    end

    class Step3 < Step2
    end
  end
end