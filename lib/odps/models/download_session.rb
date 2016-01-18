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

module AliODPS
  class DownloadSession
    attr_accessor :download_id, :owner, :initiated, :status, :schema, :block_list, :location, :record_count

    def initialize
      @json_mapping = {'DownloadID': '@download_id',
                       'Status': '@status',
                       'Owner': '@owner',
                       'Initiated': '@initiated',
                       'Schema': '@schema',
                       'RecordCount': '@record_count'}
    end

    def []=(k, v)
      self.instance_variable_set @json_mapping[k.to_sym], v
    end
  end
end