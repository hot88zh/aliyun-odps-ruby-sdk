require 'spec_helper'
require 'json'
require 'rexml/element'

describe 'Instances' do

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

  it "should create a SQL task" do
    sql_task = AliODPS::SQLTask.new 'sql_name', 'select * from articles;', 'sql_comment', [{settings: '1111111'}]
    expect(sql_task.name).to eq('sql_name')
    expect(sql_task.to_xml).to eq("<SQL><Name>sql_name</Name><Comment>sql_comment</Comment><Config><Property><Name>settings</Name><Value>1111111</Value></Property></Config><Query><![CDATA[select * from articles;]]></Query></SQL>")
  end

  it "should create a SQLPlan task" do
    sql_plan_task = AliODPS::SQLPlanTask.new 'sql_name', 'select * from articles;', 'sql_comment', [{settings: '1111111'}]
    expect(sql_plan_task.name).to eq('sql_name')
    expect(sql_plan_task.to_xml).to eq("<SQLPlan><Name>sql_name</Name><Comment>sql_comment</Comment><Config><Property><Name>settings</Name><Value>1111111</Value></Property></Config><Query><![CDATA[select * from articles;]]></Query></SQLPlan>")
  end

  it "should create a instance" do
    # sql_task = AliODPS::SQLTask.new 'sql_name', 'sql_comment', 'select * from articles;'
    # instance = @odps.create_instance 'test_instance', sql_task
    # expect(instance.location).to_not be_nil
  end

  it "should get all instances" do
    instances = @odps.get_instances nil, nil, 'Terminated'
    instances.each do |instance|
      expect(instance.status).to eq('Terminated')
    end
  end

  it "should get a instance task" do
    instance = @odps.get_instances(nil, nil, 'Terminated').last
    instance.get_tasks.each do |task|
      expect(task.name).to eq('sql_name')
    end
  end

  it "should get a instance status" do
    instance = @odps.get_instances(nil, nil, 'Terminated').last
    expect(instance.refresh_status).to eq(true)
  end

  it "should get a instance detail" do
    instance = @odps.get_instances(nil, nil, 'Terminated').last
    instance.get_detail 'sql_name'
  end

  it "should get a instance progress" do
    instance = @odps.get_instances(nil, nil, 'Terminated').last
    instance.get_progress 'sql_name'
    instance.progress.each do |s|
      expect(s.class.name).to
    end
  end

  it "should get a instance summary" do
    instance = @odps.get_instances(nil, nil, 'Terminated').last
    instance.get_summary 'sql_name'
    AliODPS::LOGGER.debug instance.summary
    AliODPS::LOGGER.debug instance.json_summary
  end

  it "should terminal a instance" do
    begin
      instance = @odps.get_instances(nil, nil, 'Terminated').last
      instance.terminate
      expect(instance.terminate).to eq(false)
    rescue AliODPS::ODPSApiError => e
      expect(e.code).to eq('InvalidStateSetting')
    end
  end
end