class PropertyLink < ApplicationRecord
  belongs_to :property, optional: true
end
