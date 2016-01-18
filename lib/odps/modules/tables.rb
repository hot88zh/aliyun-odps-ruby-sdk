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

require 'odps/models/table'

module AliODPS
  module Tables
    ##
    # Show user's all tables information.
    # [path] /projects/test_project/tables?tables&expectmarker=true
    # [method] GET
    def get_tables(name=nil, project_name=ODPS.current_project, owner=nil, marker=nil, max_items=nil)
      query = ['tables', 'expectmarker=true']
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
      uri = "projects/#{project_name}/tables?#{query.join('&')}"
      res = ODPS.conn.get uri
      tables = []
      REXML::XPath.each(REXML::Document.new(res.body), '/Tables/Table') do |element|
        tables << Table.new.deserialize(element)
      end
      tables
    end

    ##
    # Get table named +table_name+
    def get_table(table_name)
      table = Table.new
      table.name = table_name
      table.reload
      table
    end
  end
end