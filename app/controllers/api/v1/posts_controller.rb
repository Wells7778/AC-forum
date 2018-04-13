class Api::V1::PostsController < ApiController
  before_action :authenticate_user!, except: :index

  def index

  end
end
