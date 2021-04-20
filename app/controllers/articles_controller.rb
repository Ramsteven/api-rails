class ArticlesController < ApplicationController
  include Paginable
  include ErrorSerializer

  skip_before_action :authorize!, only: [:index, :show]

  def index
    articles = Article.recent.paginate(
      page: pagination_params[:number],
      per_page: pagination_params[:size]
    )
    render json: serializer.new(articles)
  end

  def show
    render json: serializer.new(Article.find(params[:id]))
  end

  def create
    article = Article.new(article_params)
    if article.valid?
    else
      raise Errors::Invalid.new({errors: article.errors.to_h})
      # render json: serializer.new(article)
    end
  end


  def serializer 
   ArticleSerializer
  end

  private

  def article_params
    ActionController::Parameters.new
  end
  
end
