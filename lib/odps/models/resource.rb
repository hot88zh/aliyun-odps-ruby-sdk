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


module AliODPS
  class Resource < XMLSerializer
    attr_accessor :name, :owner, :last_updator, :comment, :resource_type, :local_path, :creation_time,
                  :last_modified_time, :table_name, :resource, :resource_size, :file_source

    def initialize
      @root_node = 'Resource'
      node_register [String, nil, "/#{@root_node}/Name", '@name'],
                    [String, nil, "/#{@root_node}/Owner", '@owner'],
                    [String, nil, "/#{@root_node}/LastUpdator", '@last_updator'],
                    [String, nil, "/#{@root_node}/Comment", '@comment'],
                    [String, nil, "/#{@root_node}/ResourceType", '@resource_type'],
                    [String, nil, "/#{@root_node}/LocalPath", '@local_path'],
                    [String, nil, "/#{@root_node}/CreationTime", '@creation_time'],
                    [String, nil, "/#{@root_node}/LastModifiedTime", '@last_modified_time'],
                    [String, nil, "/#{@root_node}/TableName", '@table_name'],
                    [String, nil, "/#{@root_node}/ResourceSize", '@resource_size']
    end

    ##
    # Reload resource's information from ODPS.
    # [path] /projects/test_project/resources/resourcename
    # [method] HEAD
    def reload
      response = ODPS.conn.head "projects/#{ODPS.current_project}/resources/#{@name}"
      self.file_source = response['x-odps-copy-file-source']
      self.name = response['x-odps-resource-name']
      self.last_updator = response['x-odps-updator']
      self.owner = response['x-odps-owner']
      self.comment = response['x-odps-comment']
      self.last_modified_time = response['Last-Modified']
      self.creation_time = response['x-odps-creation-time']
      self.resource_type = response['x-odps-resource-type']
    end

    ##
    # Get resource content
    # [path] /projects/test_project/resources/resourcename
    # [method] GET
    def get_resource
      response = ODPS.conn.get "projects/#{ODPS.current_project}/resources/#{@name}"
      self.name = response['x-odps-resource-name']
      self.last_updator = response['x-odps-updator']
      self.owner = response['x-odps-owner']
      self.comment = response['x-odps-comment']
      self.last_modified_time = response['Last-Modified']
      self.creation_time = response['x-odps-creation-time']
      self.resource_size = response['x-odps-resource-size']
      self.resource_type = response['x-odps-resource-type']
      self.resource = response.body
      yield self if block_given?
    end

    ##
    # Delete resource
    # [path] /projects/test_project/resources/resourcename
    # [method] DELETE
    # [return] delete result: +true+ or +false+
    def delete
      res = ODPS.conn.delete "projects/#{ODPS.current_project}/resources/#{@name}"
      res.status == 204
    end


    ##
    # Update resource
    # [path] /projects/test_project/resources/resourcename
    # [method] put
    # [return] update result: +true+ or +false+
    def update()
      res = ODPS.conn.put do |req|
        req.url "projects/#{ODPS.current_project}/resources/#{@name}"
        req.headers['x-odps-resource-type'] = self.resource_type
        req.headers['x-odps-comment'] = self.comment if self.comment
        req.headers['Content-Type'] = 'text/plain'
        if self.resource_type == 'table'
          req.headers['x-odps-copy-table-source'] = self.table_name
        else
          req.body = self.resource
          req.headers['x-odps-resource-name'] = self.name
        end
      end
      res.status == 200
    end
  end
end