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
require 'odps/models/project'

module AliODPS
  ##
  # functions about *Projects* module.
  module Projects

    ##
    # Show user's all projects information.
    # [path] /projects
    # [method] GET
    def get_projects(owner=nil, marker=nil, max_items=nil)
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
      if query.length == 0
        uri = 'projects'
      else
        uri = "projects?#{query.join('&')}"
      end
      res = ODPS.conn.get uri
      projects = []
      REXML::XPath.each(REXML::Document.new(res.body),'/Projects/Project') do |element|
        projects << Project.new.deserialize(element)
      end
      projects
    end

    ##
    # Show project information. If +project_name+ is nil, the default project's
    # name will be used.
    # [path] /projects/project_name
    # [method] GET
    def get_project(project_name=
                        @default_project)
      project = Project.new
      project.name = project_name
      ODPS.current_project = project_name
      project.reload
    end
  end
end