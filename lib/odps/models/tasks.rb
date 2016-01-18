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

module AliODPS

  class SQLTask < AliODPS::XMLSerializer
    attr_accessor :name, :comment, :query, :config, :start_time, :end_time, :status

    ##
    # SQL task constructor
    # [params]
    #   +name+: Name
    #   +comment+: Comment
    #   +config+: Properties. e.g. [{name: value},{name: value}]
    #   +query+: SQL string
    def initialize(name = nil, query = nil, comment = nil, config = [])
      @root_node = 'SQL'
      @no_xml_decl = true
      @name = name
      @comment = comment
      @config = config.map do |c|
        {'Name': c.keys.first, 'Value': c.values.first}
      end
      @query = query
      node_register [String, nil, "/Task/Name", '@name'],
                    [String, nil, "/Task/StartTime", '@start_time'],
                    [String, nil, "/Task/EndTime", '@end_time'],
                    [String, nil, "/Task/Status", '@status']
    end

    def to_xml
      serialize [String, nil, 'Name', self.name],
                [String, nil, 'Comment', self.comment],
                [Array, ['Config'], 'Property', self.config],
                [String, nil, 'Query', REXML::CData.new(self.query)]
    end
  end

  class SQLPlanTask < AliODPS::XMLSerializer
    attr_accessor :name, :comment, :query, :config

    ##
    # SQLPlan task constructor
    # [params]
    #   +name+: Name
    #   +comment+: Comment
    #   +config+: Properties. e.g. [{name: value},{name: value}]
    #   +query+: SQL string
    def initialize(name = nil, query = nil, comment = nil, config = [])
      @root_node = 'SQLPlan'
      @no_xml_decl = true
      @name = name
      @comment = comment
      @config = config.map do |c|
        {'Name': c.keys.first, 'Value': c.values.first}
      end
      @query = query
      node_register [String, nil, "/Task/Name", '@name'],
                    [String, nil, "/Task/StartTime", '@start_time'],
                    [String, nil, "/Task/EndTime", '@end_time'],
                    [String, nil, "/Task/Status", '@status']
    end

    def to_xml
      serialize [String, nil, 'Name', self.name],
                [String, nil, 'Comment', self.comment],
                [Array, ['Config'], 'Property', self.config],
                [String, nil, 'Query', REXML::CData.new(self.query)]
    end
  end
end