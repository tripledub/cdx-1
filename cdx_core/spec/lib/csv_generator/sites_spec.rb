require 'spec_helper'

describe CsvGenerator::Sites do
  let(:user)        { User.make }
  let(:institution) { user.institutions.make }
  let!(:sites)      { 4.times { institution.sites.make } }
  let(:site)        { Site.first }

  subject           { described_class.new(Site.all, 'my_custom_name') }

  it 'should return a valid CSV with sites' do
    csv  = CSV.parse(subject.build_csv)
    expect(csv[0]).to eq(["Name", "Address","City", "State", "Zipcode"])
    expect(csv[1]).to eq([site.name, site.address, site.city, site.state, site.zip_code])
  end

  it 'should return a file name' do
    expect(subject.filename).to include('my_custom_name')
  end
end
