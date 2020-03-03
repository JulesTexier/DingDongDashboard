class PropertyImage < ApplicationRecord
    belongs_to :property
    validates :url, presence: true, format: { with: /https?:\/\/[\S]+/i, message: "link format is not valid" }

end
