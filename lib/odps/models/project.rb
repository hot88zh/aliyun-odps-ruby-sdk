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

  class Project < XMLSerializer
    attr_accessor :name, :comment, :owner, :state, :last_modified_time,
                  :creation_time, :project_group_name, :properties, :clusters


    def initialize
      @root_node = 'Project'
      node_register [String, nil, "/#{@root_node}/Name", '@name'],
                    [String, nil, "/#{@root_node}/Comment", '@comment'],
                    [String, nil, "/#{@root_node}/State", '@state'],
                    [String, nil, "/#{@root_node}/ProjectGroupName", '@project_group_name'],
                    [Array, Hash, "/#{@root_node}/Clusters/Cluster", '@clusters'],
                    [Array, Hash, "/#{@root_node}/Properties/Property", '@properties']

    end

    ##
    # Update comment property
    # [path] /projects/project_name
    # [method] PUT
    def update(comment)
      response = ODPS.conn.put do |req|
        req.url "projects/#{self.name}"
        req.headers['Content-Type'] = 'application/xml'
        req.body = serialize [String, nil, 'Name', @name],
                             [String, nil, 'Comment', comment]
      end
      # Update project object's +comment+ attribute
      if response.status == 200
        self.comment = comment
      end
    end

    ##
    # Reload project's information from ODPS.
    # [path] /projects/project_name
    # [method] GET
    def reload
      response = ODPS.conn.get "projects/#{self.name}"
      self.creation_time = response['x-odps-creation-time']
      self.last_modified_time = response['Last-Modified']
      self.owner = response['x-odps-owner']
      self.deserialize response.body
    end
  end
end