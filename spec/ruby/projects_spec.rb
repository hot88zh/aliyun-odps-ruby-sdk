require 'spec_helper'
require 'odps'
require 'odps/models/project'

require 'openssl'
require 'base64'

describe 'Projects' do

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

  it 'should get all projects' do
    projects = @odps.get_projects(nil,nil,10)
    expect(projects.size).to eq 10
  end

  it 'should get my default project' do
    project = @odps.get_project
    expect(project.name).to eq('doraemonzh_test')
    expect(project.properties.size).to be > 0
  end

  it 'should update project comment' do
    project = @odps.get_project
    comment = "Updated at #{Time.now}"
    project.update comment
    expect(project.comment).to eq(comment)
  end
end