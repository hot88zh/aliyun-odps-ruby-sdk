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

require 'odps/models/function'
require 'odps/models/resource'

module AliODPS

  module Functions

    ##
    # Show user's all functions information.
    # [path] /projects/test_project/registration/functions
    # [method] GET
    def get_functions(name=nil, project_name=ODPS.current_project, owner=nil, marker=nil, max_items=nil)
      query = []
      if owner
        query << "owner=#{owner}"
      end
      if marker
        query << "marker=#{marker}"
      end
      if max_items
        query << "maxitems=#{max_items}"
      end
      if name
        query << "name=#{name}"
      end
      if query.length == 0
        uri = "projects/#{project_name}/registration/functions"
      else
        uri = "projects/#{project_name}/registration/functions?#{query.join('&')}"
      end
      res = ODPS.conn.get uri
      functions = []
      REXML::XPath.each(REXML::Document.new(res.body), '/Functions/Function') do |element|
        functions << Function.new.deserialize(element)
      end

      # Translate resource_names to resource objects.
      functions.map do |f|
        f.resources = f.resources.map do |r|
          resource_obj = Resource.new
          resource_obj.name = r.split('/').last
          resource_obj
        end
        f
      end
    end

    ##
    # Create a function
    # [path] /projects/test_project/registration/functions
    # [method] POST
    # [params]
    #   +name+: function name
    #   +class_type+: function type
    #   +resource_names+: resource name array. e.g. ['resource_name1','resource_name2']
    def create_function(name, class_type, *resource_names)
      function = Function.new
      function.class_type = class_type
      function.alias = name
      function.resources = []
      res = ODPS.conn.post do |req|
        req.url "projects/#{ODPS.current_project}/registration/functions"
        req.headers['Content-Type'] = 'application/xml'
        req.body = function.serialize [String, nil, 'Alias', name],
                                      [String, nil, 'ClassType', class_type],
                                      [Array, ['Resources'], 'ResourceName', resource_names]
      end

      if res.status == 201
        function.location = res['Location']
        resource_names.each do |resource_name|
          resource = Resource.new
          resource.name = resource_name
          function.resources << resource
        end
      end
      function
    end

    ##
    # Get a function named +function_name+
    def get_function(function_name)
      get_functions(function_name).first
    end
  end

end