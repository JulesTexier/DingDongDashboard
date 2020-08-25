class HuntersController < ApplicationController
  before_action :authenticate_hunter!
end
