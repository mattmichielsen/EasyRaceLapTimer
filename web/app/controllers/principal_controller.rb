class PrincipalController < ApplicationController
  before_action :filter_needs_login
  def index
  end
end
