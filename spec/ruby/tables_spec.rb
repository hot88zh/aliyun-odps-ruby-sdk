require 'spec_helper'
require 'json'

describe 'Tables' do

  before(:example) do
    File.open(File.expand_path('../../config.json', __FILE__)) do |f|
      json = JSON.parse f.read
      @odps = AliODPS::ODPS.new json['access_key_id'],
                                json['access_key_secret'],
                                json['default_project'],
                                json['end_point'],
                                json['tunnel_end_point']
    end
  end

  it 'should get all tables' do
    @odps.get_tables.each do |table|
      expect(table.name).to_not be_nil
    end
  end

  it "should get partitions" do
    table = @odps.get_table 'articles_partitions'
    table.get_partitions
    AliODPS::LOGGER.debug table.partitions
  end

  it "should get table's detail information" do
    table = @odps.get_table 'articles'
    table.reload
    AliODPS::LOGGER.debug table
  end
end