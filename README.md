# aliyun-odps-ruby-sdk
Ruby SDK for aliyun odps

## Installation

```ruby
gem install aliyun-odps-ruby-sdk
```

## Usage

### Create a odps object

```ruby
require 'odps'

@odps = AliODPS::ODPS.new <access_key_id>,<access_key_secret>,<default_project>,<end_point>,<tunnel_end_point>
```

### Get project

```ruby
project = @odps.get_project [<project name>]

puts project.name # >> <project name>

project.properties.each do |property|
  puts property['Name']
end
```

### Create resource

```ruby
resource = @odps.create_resource <resource_type>, <file path>, [<resource name>, <comment>]
#resource = @odps.create_resource 'table', 'articles', 'resource_articles'
```

### Create function

```ruby
function = @odps.create_function <name>, <class type>, <resource names array>
puts function.name #>> <name>
```

### Create instance

```ruby
sql_task = AliODPS::SQLTask.new 'sql_name', 'select * from articles;', 'sql_comment', [{settings: 'xxx'}]
instance = @odps.create_instance 'test_instance', sql_task
```

### Tunnel

## License

Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html)