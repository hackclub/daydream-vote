class StaticPagesController < ApplicationController
  def landing
    if signed_in?
      @progress = :your_info
    end
  end
end
