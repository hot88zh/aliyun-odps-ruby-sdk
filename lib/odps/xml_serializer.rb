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
require 'rexml/xpath'

module AliODPS

  class XMLSerializer

    ##
    # Regist object's nodes.
    # [Format] [node_type,node_sub_type,node_xpath,object_attribute]
    # +node_type+: String,Array
    # +node_xpath+: //node_name
    # +object_attribute+: :@name
    def node_register(*nodes)
      @nodes = nodes
    end

    ##
    # Serialize object to xml.
    # [Nodes] Attributes that need to be serialized.
    # [Format] [[node_type,parent_node,node_name,value]]
    # +node_type+: String,Array
    # +parent_node+: parent node array
    # +node_name+: e.g. 'Name'
    # +value+: Value. e.g. Text or Array
    def serialize(*nodes)
      doc = REXML::Document.new "<#{@root_node}></#{@root_node}>"
      nodes.each do |node|
        cls = node[0]
        parent_nodes = node[1]
        node_name = node[2]
        val = node[3]

        cur_element = doc.root
        if parent_nodes
          # Loop create parent nodes
          parent_nodes.each do |pn|
            cur_element = cur_element.get_elements(pn).first || cur_element.add_element(pn)
          end
        end

        case cls.name
          when String.name
            case val.class.name
              when REXML::Document.name
                cur_element.add_element(node_name).add_element(val)
              when Fixnum.name
                cur_element.add_element(node_name).add_text(val.to_s)
              when REXML::CData.name
                cur_element.add_element(node_name).add_text(val)
              else
                cur_element.add_element(node_name).add_text(val)
            end
          when Array.name
            # Loop create elements
            if val.size > 0
              val.each do |v|
                if v.instance_of? String
                  cur_element.add_element(node_name).add_text(v)
                elsif v.instance_of? Hash
                  cur_element = cur_element.add_element node_name
                  v.each { |nn, nv| cur_element.add_element(nn.to_s).add_text(nv.to_s) }
                elsif v.instance_of? REXML::Document
                  cur_element = cur_element.add_element node_name
                  cur_element.add_element v
                end
              end
            end
          else
            AliODPS::LOGGER.warn "No support type! type=#{cls}"
        end
      end

      doc << REXML::XMLDecl.new(1.0, 'UTF-8') unless @no_xml_decl
      result = ''
      REXML::Formatters::Default.new.write doc, result
      AliODPS::LOGGER.debug "Serialize XML is #{result}"
      result
    end

    ##
    # Deserialize xml to obj according the registered nodes.
    # [Return] object
    def deserialize(body)
      doc = REXML::Document.new(body.to_s)
      @nodes.each do |node|
        cls = node[0]
        sub_cls = node[1]
        xpath = node[2]
        var = node[3]
        case cls.name
          when String.name
            REXML::XPath.each(doc, xpath) do |element|
              self.instance_variable_set(var, cls.new(element.text)) if element.has_text?
            end
          when Array.name
            arr = Array.new
            REXML::XPath.each(doc, xpath) do |element|
              case sub_cls.name
                when Hash.name
                  hash = sub_cls.new
                  element.each_element do |el|
                    hash[el.name] = el.text
                  end
                  arr << hash
                else
                  # Default sub class is string
                  element.each_element do |el|
                    arr << el.text
                  end
              end
            end
            self.instance_variable_set var, arr
          else
            AliODPS::LOGGER.warn "No support type! type=#{cls}"
        end
      end
      self
    end
  end

end