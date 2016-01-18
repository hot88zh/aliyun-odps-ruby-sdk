=begin
Copyright 2015 ZhangZhaoyuan

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

require 'odps/xml_serializer'
require 'rexml/document'
require 'odps/models/tasks'
require 'odps/models/stage'
require 'json'

module AliODPS

  class Instance < XMLSerializer
    attr_accessor :name, :owner, :status, :start_time, :end_time, :tasks, :priority, :comment, :location, :detail,
                  :progress, :json_summary, :summary

    def initialize
      @root_node = 'Instance'
      node_register [String, nil, "/#{@root_node}/Name", '@name'],
                    [String, nil, "/#{@root_node}/Owner", '@owner'],
                    [String, nil, "/#{@root_node}/Status", '@status'],
                    [String, nil, "/#{@root_node}/StartTime", '@start_time'],
                    [Array, Hash, "/#{@root_node}/EndTime", '@end_time']
    end

    ##
    # Get the instance tasks
    # [path] /projects/test_project/instances/instancename?taskstatus
    # [method] GET
    # [return] task object array
    def get_tasks
      res = ODPS.conn.get "projects/#{ODPS.current_project}/instances/#{self.name}?taskstatus"
      tasks = []
      REXML::XPath.each(REXML::Document.new(res.body), '/Instance/Tasks/Task') do |element|
        case element.attribute('Type').value
          when 'SQL'
            tasks << SQLTask.new.deserialize(element)
          when 'SQLPlan'
            tasks << SQLPlanTask.new.deserialize(element)
          else
            AliODPS::LOGGER.warn "Unknown task type: #{element.attribute('Type').value}"
        end
      end
      tasks
    end

    ##
    # Refresh instance status
    # [path] /projects/test_project/instances/instancename
    # [method] GET
    # [return] refresh result: +true+ or +false+
    def refresh_status
      res = ODPS.conn.get "projects/#{ODPS.current_project}/instances/#{self.name}"
      self.deserialize res.body
      res.status == 200
    end

    ##
    # Get a instance detail
    # [path] /projects/projectname/instances/instancename?instancedetail&taskname=taskname
    # [method] GET
    # [return] detail hash object. e.g. detail['JsonSummary']
    def get_detail(task_name)
      res = ODPS.conn.get "projects/#{ODPS.current_project}/instances/#{self.name}?instancedetail&taskname=#{task_name}"
      if res.status == 200
        obj = JSON.parse(res.body)
        if obj.has_key? 'Instance'
          self.detail = obj['Instance']
        end
      end
      self.detail
    end

    ##
    # Get a instance task execute progress
    # [path] /projects/projectname/instances/instancename?instanceprogress&taskname=taskname
    # [method] GET
    # [return] progress array. e.g. [+Stage+ Object...]
    def get_progress(task_name)
      res = ODPS.conn.get "projects/#{ODPS.current_project}/instances/#{self.name}?instanceprogress&taskname=#{task_name}"
      progress = []
      REXML::XPath.each(REXML::Document.new(res.body), '/Progress/Stage') do |element|
        stage = Stage.new.deserialize(element)
        stage.id = element.attribute['ID'].value
        progress << stage
      end
      self.progress = progress
      progress
    end

    ##
    # Get a instance task summary
    # [path] /projects/projectname/instances/instancename?instancesummary&taskname=taskname
    # [method] GET
    # [return] a hash object. obj['Summary'],obj['JsonSummary']
    def get_summary(task_name)
      res = ODPS.conn.get "projects/#{ODPS.current_project}/instances/#{self.name}?instancesummary&taskname=#{task_name}"
      obj = JSON.parse res.body
      if obj.has_key? 'Instance'
        self.json_summary = obj['Instance']['JsonSummary']
        self.summary = obj['Instance']['Summary']
      end
      obj['Instance']
    end

    ##
    # Terminate a instance
    # [path] /projects/test_project/instances/instancname
    # [method] PUT
    # [return] terminate result. +true+ or +false+
    def terminate
      res = ODPS.conn.put do |req|
        req.url "projects/#{ODPS.current_project}/instances/#{self.name}"
        req.headers['Content-Type'] = 'application/xml'
        req.body = self.serialize [String, nil, 'Status', 'Terminated']
      end
      self.location = res['Location']
      res.status == 200
    end
  end

end