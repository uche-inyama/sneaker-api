require 'rails_helper'

RSpec.describe Sample, type: :model do
  it "validates the presence of sample attributes" do
    expect(Sample.new()).not_to be_valid
  end
end
