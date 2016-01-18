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

require 'json'
require 'odps/models/upload_session'
require 'odps/models/download_session'

module AliODPS

  module Tunnel

    ##
    # Create a upload session
    # [path] /projects/<project name>/tables/<table name>?partition=<partition_spec>&uploads
    # [method] POST
    # [return] +UploadSession+ object
    def create_upload_session(table_name, partition = nil)
      if partition
        url = "projects/#{ODPS.current_project}/tables/#{table_name}?partition=#{partition}&uploads"
      else
        url = "projects/#{ODPS.current_project}/tables/#{table_name}?uploads"
      end
      res = ODPS.tunnel_conn.post do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
      end
      JSON.parse res.body, {object_class: UploadSession}
    end

    ##
    # Create a download session
    # [path] /projects/<project name>/tables/<table name>?partition=<partition_spec>&downloads
    # [method] POST
    # [return] +DownloadSession+ object
    def create_download_session(table_name, partition = nil)
      if partition
        url = "projects/#{ODPS.current_project}/tables/#{table_name}?partition=#{partition}&downloads"
      else
        url = "projects/#{ODPS.current_project}/tables/#{table_name}?downloads"
      end
      res = ODPS.tunnel_conn.post do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
      end
      JSON.parse res.body, {object_class: DownloadSession}
    end
  end

end