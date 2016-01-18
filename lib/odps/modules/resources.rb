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

require 'odps/models/resource'

module AliODPS
  module Resources
    ##
    # Show user's all resources information.
    # [path] /projects/test_project/resources
    # [method] GET
    def get_resources(name=nil, project_name=ODPS.current_project, owner=nil, marker=nil, max_items=nil)
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
        uri = "projects/#{project_name}/resources"
      else
        uri = "projects/#{project_name}/resources?#{query.join('&')}"
      end
      res = ODPS.conn.get uri
      resources = []
      REXML::XPath.each(REXML::Document.new(res.body), '/Resources/Resource') do |element|
        resources << Resource.new.deserialize(element)
      end
      resources
    end

    ##
    # Create resource.
    # [path] /projects/test_project/resources/
    # [method] POST
    # [params]
    #   +type+: table,py,jar,archive,file
    #   +file+: if type is table, +file+ is the table source. Otherwise +file+
    #           is the +File+ object or file path.
    #   +resource_name+(Optional): Default is filename or table source name.
    #   +comment(Optional)+
    def create_resource(type, file, resource_name=nil, comment=nil)
      if type != 'table' and !file.instance_of? File
        file = File.open(file)
      end
      begin
        resource_name = resource_name || File.basename(file)
        res = ODPS.conn.post do |req|
          req.url "projects/#{ODPS.current_project}/resources"
          req.headers['x-odps-resource-type'] = type
          req.headers['x-odps-resource-name'] = resource_name
          req.headers['x-odps-comment'] = comment if comment
          req.headers['Content-Type'] = 'text/plain'
          if type == 'table'
            req.headers['x-odps-copy-table-source'] = file
          else
            req.body = file.read
          end
        end
      rescue Exception, e
        AliODPS::LOGGER.error "Open file error!#{$!}@#{$@}"
      ensure
        file.close unless type == 'table'
      end

      resource = Resource.new
      if res.status == 201
        resource.comment = comment
        resource.file_source = res['Location']
        resource.name = resource_name
      end
      resource
    end

    ##
    # Get resource content
    # [path] /projects/test_project/resources/resourcename
    # [method] GET
    # [params]
    #   +name+: resource_name
    def get_resource(name)
      resource = Resource.new
      resource.name = name
      resource.get_resource
      yield resource.resource if block_given?
      resource
    end
  end
end