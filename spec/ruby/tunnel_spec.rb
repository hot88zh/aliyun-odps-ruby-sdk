require 'spec_helper'
require 'json'
require 'odps/models/upload_session'
require 'odps/models/download_session'

describe 'Tunnel' do

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

  it "should deserialize a string to upload session object" do
    json = '{"UploadID": "<uploadid>","Status": "normal/closed/canceled/expired/critical/closing","Owner": "<user account>", "Initiated": "<date>", "Schema": "<table schema in Json>"}'
    expect(JSON.parse(json, {object_class: AliODPS::UploadSession}).upload_id).to eq('<uploadid>')
  end

  it "should create a upload session" do
    upload_session = @odps.create_upload_session 'articles'
    expect(upload_session).to be_an_instance_of(AliODPS::UploadSession)
    expect(upload_session.status).to eq('normal')
  end

  it "should upload a file" do

  end

  it "should get a upload session status" do

  end

  it "should commit a upload session" do

  end

  it "should create a download session" do
    download_session = @odps.create_download_session 'articles'
    expect(download_session).to be_an_instance_of(AliODPS::DownloadSession)
    expect(download_session.status).to eq('normal')
  end

  it "should get a table download" do

  end

end