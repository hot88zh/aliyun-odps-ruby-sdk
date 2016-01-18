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

require 'faraday'
require 'logger'

module AliODPS

  class << self

    def require_libs(*libs)
      libs.each { |lib| require "odps/#{lib}" }
    end

    def require_modules(*modules)
      modules.each { |m| require_libs "modules/#{m}" }
    end

    def require_models(*models)
      models.each { |m| require_libs "models/#{m}" }
    end

    def require_middle_wares(*middle_wares)
      middle_wares.each { |m| require_libs "middlewares/#{m}" }
    end
  end

  LOGGER = Logger.new STDOUT
  LOGGER.level = Logger::DEBUG

  require_libs 'version'
  require_modules 'functions', 'instances', 'projects', 'resources', 'tables', 'tunnel'
  require_models 'column', 'function', 'instance', 'project', 'resource', 'table', 'tasks'
  require_middle_wares 'auth_header'


  ##
  # ODPS class
  class ODPS
    include Projects, Resources, Tables, Functions, Instances, Tunnel

    class << self
      attr_accessor :access_key_id, :access_key_secret, :conn, :current_project, :tunnel_conn
    end
    ##
    # The constructor
    def initialize(access_id, access_key_secret, default_project, end_point, tunnel_end_point)
      ODPS.access_key_id = access_id
      ODPS.access_key_secret = access_key_secret
      @default_project = default_project
      ODPS.current_project = default_project
      # Init ODPS connection
      ODPS.conn = Faraday.new(url: end_point) do |conn|
        conn.request :multipart
        conn.request :url_encoded
        conn.use ODPSAuthHeader, conn.url_prefix
        conn.response :logger
        conn.adapter Faraday.default_adapter
      end
      # Init Tunnel connection
      ODPS.tunnel_conn = Faraday.new(url: tunnel_end_point) do |conn|
        conn.request :multipart
        conn.request :url_encoded
        conn.use ODPSAuthHeader, conn.url_prefix
        conn.response :logger
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
