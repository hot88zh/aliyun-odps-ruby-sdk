require 'spec_helper'
require 'json'
require 'odps/odps_errors'

describe 'Functions' do

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

  it 'should create a function' do
    function = @odps.create_function 'function_test', 'ExtractName', 'resource_articles'
    expect(function.alias).to eq('function_test')
  end

  it "should get all functions" do
    @odps.get_functions.each do |f|
      AliODPS::LOGGER.debug f.alias
    end
  end

  it "should update a function" do
    function = @odps.get_function 'function_test'
    expect(function.update('function_test', 'ChangedClassType', 'resource_articles')).to be(true)
  end

  it "should delete a function" do
    function = @odps.get_function 'function_test'
    AliODPS::LOGGER.debug function
    expect(function.delete).to be(true)
  end
end