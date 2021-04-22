require 'rails_helper'

RSpec.describe "/articles/:article_id/comments", type: :request do
   
  let(:article) { create :article }
  let(:comments_path){ "/articles/#{article.id}/comments" } 

  describe "GET /index" do
    subject { get article_comments_url(article_id: article.id), as: :json }

    it "renders a successful response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "should return only comments belonging to article" do
      comment = create :comment, article: article
      create :comment
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end
  
    it "should paginate results" do
      comments = create_list :comment, 3, article: article
      get article_comments_url(article_id: article.id, page:{ number:2, size: 1}), as: :json
      expect(json_data.length).to eq(1)
      comment = comments.second
      expect(json_data.first[:id]).to eq(comment.id.to_s)
    end
    
    it 'should have proper json body' do
      comment = create :comment, article: article
      subject
      expect( json_data.first[:attributes]).to eq({'content': comment.content})
    end
    
    it 'should have related objects information in the response' do
      user = create :user
      create :comment, article: article, user: user
      subject
      relationships = json_data.first[:relationships]
      expect(relationships[:article][:data][:id]).to eq(article.id.to_s)
      expect(relationships[:user][:data][:id]).to eq(user.id.to_s)
    end

  end


  describe "POST /create" do
   
    context 'when not authorized' do
      subject {post article_comments_url(article_id: article.id)}
      it_behaves_like 'forbidden_requests'
    end

    context 'when  authorized' do
      let(:valid_attributes)  do
        { data:{  attributes: {content: 'My awesome comment for article' }}}
      end

      let(:invalid_attributes) {{ data:{ attributes:  { content: '' } }}}
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      let(:valid_headers) {{ 'authorization' =>  "Bearer #{access_token.token}" }}

        context "with valid parameters" do
          subject {  post article_comments_url(article_id: article.id),
                     params: valid_attributes.merge(article_id: article.id) , headers: valid_headers, as: :json }
            

          it 'return 201 status code' do
            subject
            expect(response).to have_http_status(:created)
          end

          it "creates a new Comment" do
            expect { subject }.to change(article.comments, :count).by(1)
          end

          it "renders a JSON response with the new comment" do
            subject
            expect(json_data[:attributes]).to eq({
              'content': 'My awesome comment for article'
            })
          end
        end

        context "with invalid parameters" do
          subject {  post article_comments_url(article_id: article.id),
                       params: invalid_attributes.merge(article_id: article.id), headers: valid_headers, as: :json }

          it "Should return 422 status" do
            subject 
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "renders a JSON response with errors for the new comment" do
            subject
            expect(json[:errors]).to include({
            "detail": "can't be blank",
            "source":{"pointer": "/data/attributes/content"},
            "status": 422,
            "title": "Invalid request"})
          end
       end
    end
  end
end
