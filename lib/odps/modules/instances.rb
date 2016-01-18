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

require 'rexml/document'

module AliODPS

  module Instances

    ##
    # Show user's all instances information.
    # [path] /projects/test_project/instances
    # [method] GET
    def get_instances(job_name=nil, date_range=nil, status=nil, only_owner=nil,
                      project_name=ODPS.current_project, marker=nil, max_items=nil)
      query = []
      if date_range
        query << "daterange=#{date_range}"
      end
      if marker
        query << "marker=#{marker}"
      end
      if max_items
        query << "maxitems=#{max_items}"
      end
      if job_name
        query << "jobname=#{job_name}"
      end
      if status
        query << "status=#{status}"
      end
      if only_owner
        query << "onlyowner=#{only_owner}"
      end
      if query.length == 0
        uri = "projects/#{project_name}/instances"
      else
        uri = "projects/#{project_name}/instances?#{query.join('&')}"
      end
      res = ODPS.conn.get uri
      instances = []
      REXML::XPath.each(REXML::Document.new(res.body), '/Instances/Instance') do |element|
        instances << Instance.new.deserialize(element)
      end
      instances
    end

    ##
    # Create a task instance
    # [path] /projects/test_project/instances
    # [method] POST
    # [return] Instance object
    def create_instance(name, tasks, priority = 1, comment = nil)
      instance = Instance.new
      instance.name = name
      instance.priority = priority
      instance.comment = comment if comment
      if tasks.instance_of? Array
        instance.tasks = tasks
      else
        instance.tasks = [tasks]
      end

      res = ODPS.conn.post do |req|
        req.url "projects/#{ODPS.current_project}/instances"
        req.headers['Content-Type'] = 'application/xml'
        req.body = instance.serialize [String, ['Job'], 'Name', name],
                                      [String, ['Job'], 'Comment', comment],
                                      [String, ['Job'], 'Priority', priority],
                                      [Array, ['Job'], 'Tasks', instance.tasks.map { |t| REXML::Document.new t.to_xml }]
      end

      if res.status == 201
        instance.location = res['Location']
        instance
      end
    end
  end

end