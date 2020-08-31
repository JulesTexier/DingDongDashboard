module Wizard
  module SubscriberResearch
    STEPS = %w(step1 step2).freeze

    class Base
      include ActiveModel::Model
      attr_accessor :subscriber_research

      delegate *::Research.attribute_names.map { |attr| [attr, "#{attr}="] }.flatten, to: :subscriber_research

      def initialize(subscriber_research_attributes)
        @subscriber_research = ::Research.new(subscriber_research_attributes)
      end
    end

    class Step1 < Base
      validates :agglomeration, presence: true
    end
    
    class Step2 < Step1

      validates :min_surface, presence: true
      validates :min_price, presence: true
    end
  end
end