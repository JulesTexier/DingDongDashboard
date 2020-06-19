class HuntersController < ApplicationController
  before_filter :authenticate_hunter!
  
end
