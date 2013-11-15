# gem install aws-sdk-core --pre
require 'aws-sdk-core'

class NerdDynamo
  def initialize
    Aws.config = {
      access_key_id: ENV['MY_AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['MY_AWS_SECRET_ACCESS_KEY'],
      region: ENV['MY_AWS_REGION']
    }
  end

  def spin_up
    puts "Spinning up #{app}"
    unless table_exists?
      build_table
      puts "Table '#{table_name}' is now #{status}"
    else
      puts "Found existing table '#{table_name}'"
    end

    puts "\nCreating items"
    nerd_list.each do |nerd|
      load_item(nerd)
    end
    puts "\n#{app} is online"
  end

  def spin_down
    puts "Shutting-down #{app}"
    dynamo.delete_table(table_name: table_name) if table_exists?
    sleep 1 while table_exists? && status == 'DELETING'
    puts "\n#{app} is down"
  end

  private

    def app
      self.class.name
    end

    def table_exists?
      dynamo.list_tables.table_names.include?(table_name)
    end

    def nerd_list
      [
        { name: 'Bill', title: 'Integration Engineer' },
        { name: 'Pete', title: 'Senior Network Administrator' },
        { name: 'Keith', title: 'Web Developer' },
        { name: 'Michael', title: 'Integration Engineer' },
        { name: 'Ben', title: 'Network Administrator' }
      ]
    end

    def dynamo
      @dynamo ||= Aws::DynamoDB.new
    end

    def table_name
      'Nerds'
    end

    def status
      dynamo.describe_table(table_name: table_name).table.table_status
    end

    def build_table
      puts "Creating table '#{table_name}'..."
      dynamo.create_table({
        table_name: table_name,
        key_schema: [{
          attribute_name: 'name',
          key_type: 'HASH'
        }],
        provisioned_throughput: {
          read_capacity_units: 1,
          write_capacity_units: 1
        },
        attribute_definitions: [
          {
            attribute_name: 'name',
            attribute_type: 'S'
          }
        ]
      })
      sleep 1 while status == 'CREATING'
    end

    def load_item item
      # will overwrite if exists
      dynamo.update_item({
        table_name: table_name,
        key: { name: { s: item[:name] } },
        attribute_updates: {
          title: {
            value: { s: item[:title] },
            action: 'PUT'
          }
        }
      })
    end
end

if __FILE__ == $0
  unless ARGV[0]
    options = NerdDynamo.public_instance_methods(false).join('|')
    $stderr.puts "USAGE: #{$0} [#{options}]"
  else
    NerdDynamo.new.send(ARGV[0])
  end
end
