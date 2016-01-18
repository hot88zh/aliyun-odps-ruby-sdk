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
require 'odps/models/column'
require 'json'
require 'rexml/document'

module AliODPS
  class Table < XMLSerializer
    attr_accessor :owner, :last_modified_time, :creation_time, :name, :table_id, :comment, :schema,
                  :hub_lifecycle, :is_virtual_view, :last_ddl_time, :lifecycle, :partition_keys, :shard_exist,
                  :size, :table_label, :columns, :partitions

    def initialize
      @root_node = 'Table'
      node_register [String, nil, "/#{@root_node}/Name", '@name'],
                    [String, nil, "/#{@root_node}/Owner", '@owner'],
                    [String, nil, "/#{@root_node}/TableId", '@table_id'],
                    [String, nil, "/#{@root_node}/Comment", '@comment'],
                    [String, nil, "/#{@root_node}/Schema", '@schema']
    end

    ##
    # Get table information
    # [path] /projects/test_project/tables/test_table
    # [method] GET
    def reload
      res = ODPS.conn.get "projects/#{ODPS.current_project}/tables/#{self.name}"
      self.deserialize res.body
      if self.schema
        j = JSON.parse self.schema
        self.last_modified_time = j['lastModifiedTime']
        self.creation_time = j['createTime']
        self.hub_lifecycle = j['hubLifecycle']
        self.is_virtual_view = j['isVirtualView']
        self.last_ddl_time = j['lastDDLTime']
        self.lifecycle = j['lifecycle']
        self.partition_keys = j['partitionKeys']
        self.shard_exist = j['shardExist']
        self.size = j['size']
        self.table_label = j['tableLabel']
        self.columns = j['columns'].map { |c| Column.new(c['comment'], c['label'], c['name'], c['type']) }
      end
    end

    ##
    # Get table partitions
    # [path] /projects/test_project/tables/table_name?partitions
    # [method] GET
    # self.partitions => [[col,col],[col,col],...]
    # col => {name: xx, value: xx}
    def get_partitions
      res = ODPS.conn.get "projects/#{ODPS.current_project}/tables/#{self.name}?partitions"
      partitions = []
      REXML::XPath.each(REXML::Document.new(res.body), '/Partitions/Partition') do |element|
        cols = []
        element.each_element do |col|
          cols << {name: col.attributes['Name'], value: col.attributes['Value']}
        end
        partitions << cols
      end
      self.partitions = partitions
    end
  end
end