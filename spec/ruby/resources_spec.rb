require 'spec_helper'
require 'odps'
require 'odps/models/resource'
require 'json'
require 'openssl'
require 'base64'

describe 'Resources' do

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

  it 'should get all my resources' do
    resources = @odps.get_resources
    expect(resources.size).to be >= 0
  end

  it "should create py resource" do
    resource = @odps.create_resource 'py', File.expand_path('../misc/cal_res.py', __FILE__)
    expect(resource.name).to eq('cal_res.py')
  end

  it "should create table resource" do
    resource = @odps.create_resource 'table', 'articles', 'resource_articles'
    expect(resource.name).to eq('resource_articles')
  end

  it "should reload resource from odps" do
    resource = @odps.get_resources.first
    resource.reload
  end

  it "should get resource content from odps" do
    resource = @odps.get_resource('cal_res.py') do |content|
      File.open(File.expand_path('../misc/cal_res_downloaded.py', __FILE__), 'wb') do |file|
        file.write content
      end
    end
    expect(resource.name).to eq('cal_res.py')
  end

  it "should update resource comment" do
    resource = @odps.get_resource('cal_res.py')
    resource.comment = "Updated at #{Time.now}"
    update_result = resource.update
    expect(update_result).to eq(true)
  end

  it "should update resource table name" do
    resource = @odps.get_resource('resource_articles')
    AliODPS::LOGGER.debug "resource.name=#{resource.name}"
    resource.table_name = 'abcd'
    update_result = resource.update
    expect(update_result).to eq(true)
  end

  it "should update resource content" do
    resource = @odps.get_resource('cal_res.py')
    File.open(File.expand_path('../misc/cal_res_update.py', __FILE__)) do |file|
      resource.resource = file.read
    end
    update_result = resource.update
    expect(update_result).to eq(true)
  end

  it "should delete resource" do
    resource = @odps.get_resource('cal_res.py')
    result = resource.delete
    expect(result).to eq true

    resource = @odps.get_resource('resource_articles')
    result = resource.delete
    expect(result).to eq true
  end
end