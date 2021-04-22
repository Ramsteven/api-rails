class CommentsController < ApplicationController
   include Paginable
   skip_before_action :authorize!, only: :index
   before_action :load_article

  # GET /comments
  def index
    comments = @article.comments.paginate(
      page: pagination_params[:number],
      per_page: pagination_params[:size]
    )

    render json: serializer.new(comments)
  end

  # POST /comments
  def create
    @comment = @article.comments.build(comment_params.merge(user: current_user))

    if @comment.save!
      render json: serializer.new(@comment), status: :created, location: @article
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

 def serializer 
   CommentSerializer
  end

  private

  def load_article
    @article = Article.find(params[:article_id])
  end

    # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:data).require(:attributes).permit(:content) || ActionController::Parameters.new
  end
end
