require 'rails_helper'

RSpec.describe User, type: :model do
  it "requires the presence of user attributes" do
    expect(User.new()).not_to be_valid
    expect(User.new(
      email: "johndoe@gmail.com", 
      username: "john", 
      password: "abcd1234", 
      password_confirmation: "abcd1234")).to be_valid
  end
end
