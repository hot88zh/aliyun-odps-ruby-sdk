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
require 'odps/odps_errors'

module AliODPS

  class Function < XMLSerializer
    attr_accessor :alias, :owner, :class_type, :creation_time, :resources, :location

    def initialize
      @root_node = 'Function'
      node_register [String, nil, "/#{@root_node}/Alias", '@alias'],
                    [String, nil, "/#{@root_node}/Owner", '@owner'],
                    [String, nil, "/#{@root_node}/ClassType", '@class_type'],
                    [String, nil, "/#{@root_node}/CreationTime", '@creation_time'],
                    [Array, String, "/#{@root_node}/Resources", '@resources']
    end

    ##
    # Delete function
    # [path] /projects/test_project/registration/functions/functionname
    # [method] DELETE
    # [return] delete result +true+ or +false+
    def delete
      res = ODPS.conn.delete "projects/#{ODPS.current_project}/registration/functions/#{self.alias}"
      res.status == 204
    end

    ##
    # Update function
    # [path] /projects/test_project/registration/functions/Extract_Name
    # [method] PUT
    # [return] Update result: +true+ or +false+
    def update(name=nil, class_type=nil, *resource_names)
      res = ODPS.conn.put do |req|
        req.url "projects/#{ODPS.current_project}/registration/functions/#{self.alias}"
        req.headers['Content-Type'] = 'application/xml'
        req.body = serialize [String, nil, 'Alias', name],
                             [String, nil, 'ClassType', class_type],
                             [Array, ['Resources'], 'ResourceName', resource_names]
      end
      res.status == 200
    end
  end

end