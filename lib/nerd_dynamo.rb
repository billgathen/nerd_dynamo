# gem install aws-sdk-core --pre
#
# To run you'll need an active AWS account
# that's been configured to use DynamoDB
#
# Your Aws.config info should be stored in
# - ENV['AWS_ACCESS_KEY_ID'],
# - ENV['AWS_SECRET_ACCESS_KEY'],
# - ENV['AWS_REGION']
# otherwise, uncomment the initialize method and adjust appropriately
# DON'T HARDCODE INLINE!
#
require 'aws-sdk-core'
require 'multi_json'

class NerdDynamo
  def initialize
    # Aws.config = {
    #   access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    #   secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    #   region: ENV['AWS_REGION']
    # }
  end

  def spin_up
    build_table
    nerd_list.each { |nerd| load_item(nerd) }
    "#{app} is up"
  end

  def spin_down
    drop_table
    "#{app} is down"
  end

  def show
    return [] unless table_exists?

    rsp = dynamo.scan(
      table_name: table_name,
      attributes_to_get: [ 'name', 'title' ]
    )

    rsp.items.
      map{ |i| { name: i['name'].s, title: i['title'].s } }.
      sort{ |a,b| a[:name] <=> b[:name] }
  end

  def add name, title
    return [] unless table_exists?

    load_item({ 'name' => name, 'title' => title })
  end

  def find name
    return [] unless table_exists?

    rsp = dynamo.get_item(
      table_name: table_name,
      key: { 'name' => { s: name } },
      attributes_to_get: [ 'name', 'title' ]
    )
    if rsp.item
      [{ name: rsp.item['name'].s, title: rsp.item['title'].s }]
    else
      []
    end
  end

  def show_as_text
    show.map{ |i| "#{i[:name]} (#{i[:title]})" }.join("\n")
  end

  def self.actions
    public_instance_methods(false).map(&:to_s)
  end

  private

    def app
      self.class.name
    end

    def table_exists?
      dynamo.list_tables.table_names.include?(table_name)
    end

    def nerd_list
      MultiJson.load(s3.get_object(bucket: "nerddynamolist", key: "nerd_list.json").body.string)
    end

    def dynamo
      @dynamo ||= Aws::DynamoDB.new
    end

    def s3
      @s3 ||= Aws::S3.new
    end

    def table_name
      'Nerds'
    end

    def status
      dynamo.describe_table(table_name: table_name).table.table_status
    end

    def build_table
      return if table_exists?
      dynamo.create_table({
        table_name: table_name,
        key_schema: [{ attribute_name: 'name', key_type: 'HASH' }],
        provisioned_throughput: { read_capacity_units: 1, write_capacity_units: 1 },
        attribute_definitions: [ { attribute_name: 'name', attribute_type: 'S' } ]
      })
      sleep 1 while status == 'CREATING'
    end

    def drop_table
      return unless table_exists?
      dynamo.delete_table(table_name: table_name)
      sleep 1 while table_exists?
    end

    def load_item item
      # will create if doesn't exist
      dynamo.update_item({
        table_name: table_name,
        key: { name: { s: item['name'] } },
        attribute_updates: {
          title: { value: { s: item['title'] }, action: 'PUT' }
        }
      })
    end
end

if __FILE__ == $0
  actions = NerdDynamo.actions
  unless ARGV[0]
    $stderr.puts "USAGE: #{$0} [#{actions.join('|')}]"
  else
    nd = NerdDynamo.new
    ARGV.each do |action|
      puts nd.send(action) if actions.include?(action)
    end
  end
end
