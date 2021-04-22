require 'rails_helper'

RSpec.describe "/articles/:article_id/comments", type: :request do
   
  let(:article) { create :article }
  let(:comments_path){ "/articles/#{article.id}/comments" } 

  describe "GET /index" do

    it "renders a successful response" do
      get comments_path
      expect(response).to have_http_status(:ok)
    end
  end


  describe "POST /create" do
    let(:valid_attributes) { {content: 'My awesome comment for article' }}
    let(:invalid_attributes) { { content: '' } }

    context 'when not authorized' do
      subject { post article_comments_url(article_id: article.id) }
      it_behaves_like 'forbidden_requests'
    end

    context 'when  authorized' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      let(:valid_headers) {{ 'authorization' =>  "Bearer #{access_token.token}" }}

        context "with valid parameters" do
          it "creates a new Comment" do
            expect {
              post article_comments_url(article_id: article.id),
              params: { article_id: article.id, comment: valid_attributes }, headers: valid_headers, as: :json
            }.to change(Comment, :count).by(1)
          end

          it "renders a JSON response with the new comment" do
            post article_comments_url(article_id: article.id), params: {  
              article_id: article.id, comment: valid_attributes }, headers: valid_headers, as: :json
            expect(response).to have_http_status(:created)
            expect(response.content_type).to match(a_string_including("application/json"))
            expect(response.location).to eq(article_url(article))
          end
        end

        context "with invalid parameters" do
          it "does not create a new Comment" do
            expect {
              post article_comments_url(article_id: article.id),
                   params: {  article_id: article.id, comment: invalid_attributes }, headers: valid_headers, as: :json
            }.to change(Comment, :count).by(0)
          end

          it "renders a JSON response with errors for the new comment" do
             post article_comments_url(article_id: article.id) ,params: { 
               article_id: article.id, comment: invalid_attributes }, headers: valid_headers, as: :json
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to eq("application/json; charset=utf-8")
          end
       end
    end
  end
end
