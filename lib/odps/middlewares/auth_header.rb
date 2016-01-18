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

require 'odps'
require 'odps/odps_errors'
require 'time'
require 'uri'
require 'faraday'
require 'openssl'
require 'base64'
require 'digest'

module AliODPS
  ##
  # Middleware for generating authorization header
  class ODPSAuthHeader < Faraday::Middleware

    def initialize(app = nil, url_prefix)
      @url_prefix = url_prefix
      super app
    end

    def call(request_env)
      date = Time.now.gmtime.strftime('%a, %d %b %Y %H:%M:%S GMT')
      canonicalized_odps_headers = get_canonicalized_odps_headers request_env[:request_headers]
      canonicalized_resource = get_canonicalized_resource request_env[:url]

      if request_env[:body].nil?
        content_md5 = ''
      else
        if request_env[:body].respond_to? :read
          body = request_env[:body].read
        else
          body = request_env[:body]
        end
        content_md5 = Digest::MD5.hexdigest body
        request_env[:request_headers]['Content-MD5'] = content_md5
      end

      # Calculate signature
      signature = ''
      if canonicalized_odps_headers.empty?
        sign_data = "#{request_env[:method].to_s.upcase}\n#{content_md5}\n#{request_env[:request_headers]['Content-Type']}\n#{date}\n#{canonicalized_resource}"
      else
        sign_data = "#{request_env[:method].to_s.upcase}\n#{content_md5}\n#{request_env[:request_headers]['Content-Type']}\n#{date}\n#{canonicalized_odps_headers}\n#{canonicalized_resource}"
      end

      AliODPS::LOGGER.debug "sign_data=#{sign_data.dump}"

      begin
        digest = OpenSSL::Digest.new 'sha1'
        hmac = OpenSSL::HMAC.digest digest, ODPS.access_key_secret, sign_data
        signature = Base64.encode64(hmac)
      rescue Exception
        raise AuthException, "Sign Error!Message is #{$!} at #{$@}"
      end

      authorization = "ODPS #{ODPS.access_key_id}:#{signature.chomp}"
      header = {Date: date, Authorization: authorization}
      request_env[:request_headers].merge!(header)

      @app.call(request_env).on_complete do |response_env|
        AliODPS::LOGGER.debug response_env[:body]
        raise ODPSApiError, response_env[:body] if response_env[:status] > 300
      end
    end

    private

    def get_canonicalized_odps_headers(headers)
      # Find all headers with 'x-odps-' prefix
      odps_headers = {}
      headers.each_pair do |k, v|
        key = k.to_s.downcase
        if key.index('x-odps-') == 0
          if odps_headers.has_key? key
            odps_headers[key] = "#{odps_headers[key]},#{v}"
          else
            odps_headers[key] = v
          end
        end
      end

      # Sort key & join
      kv_array = []
      odps_headers.keys.sort.each do |k|
        kv_array << "#{k}:#{odps_headers[k]}"
      end
      kv_array.join "\n"
    end

    def get_canonicalized_resource(uri)
      resource = []
      # Set common request parameter
      if uri.query
        uri.query += "&curr_project=#{ODPS.current_project}"
      else
        uri.query = "curr_project=#{ODPS.current_project}"
      end

      URI.decode(uri.query).split('&').each do |arr_item|
        resource << arr_item
      end
      resource.sort!
      if @url_prefix.path == '/'
        prefix_len = 0
      else
        prefix_len = @url_prefix.path.length
      end
      "#{uri.path[prefix_len..-1]}?#{resource.join '&'}"
    end
  end
end