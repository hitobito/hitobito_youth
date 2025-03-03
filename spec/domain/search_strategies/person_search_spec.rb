require "spec_helper"

describe SearchStrategies::PersonSearch do
  before do
    people(:bottom_leader).update!(j_s_number: 12345)
  end

  describe "#search_fulltext" do
    let(:user) { people(:top_leader) }

    it "finds accessible person by j_s number" do
      result = search_class(people(:bottom_leader).j_s_number.to_s).search_fulltext

      expect(result).to include(people(:bottom_leader))
    end
  end

  def search_class(term = nil, page = nil)
    described_class.new(user, term, page)
  end
end
