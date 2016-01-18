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

  class Stage < XMLSerializer
    attr_accessor :id, :status, :terminated_workers, :running_workers, :total_workers, :input_records, :output_records

    def initialize
      @root_node = 'Stage'
      node_register [String, nil, "/#{@root_node}/Status", '@status'],
                    [String, nil, "/#{@root_node}/TerminatedWorkers", '@terminated_workers'],
                    [String, nil, "/#{@root_node}/RunningWorkers", '@running_workers'],
                    [String, nil, "/#{@root_node}/TotalWorkers", '@total_workers'],
                    [String, nil, "/#{@root_node}/InputRecords", '@input_records'],
                    [String, nil, "/#{@root_node}/OutputRecords", '@output_records']
    end
  end

end