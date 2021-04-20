require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe "#validations" do
    it "shoulb have valid factory" do
      
    end

    it 'should validate token' do
      user = create :user
      access_token = user.create_access_token
      expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end
