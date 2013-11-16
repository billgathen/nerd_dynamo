require_relative 'lib/nerd_dynamo'
require 'sinatra'

get '/' do
  @nerds = NerdDynamo.new.show.sort{ |a,b| a[:name] <=> b[:name] }
  erb :index
end

get '/spin_up' do
  NerdDynamo.new.spin_up
  redirect '/'
end

get '/spin_down' do
  NerdDynamo.new.spin_down
  redirect '/'
end

__END__

@@index
<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Nerd Dynamo!</title>
  <link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css">
  <script src="//netdna.bootstrapcdn.com/bootstrap/3.0.2/js/bootstrap.min.js"></script>
</head>
<body>
  <div class="container">
    <div class="pull-left">
      <h1>Nerd Dynamo!</h1>
    </div>
    <div class="pull-right">
      <a href="/spin_up" class="btn btn-success">Spin up that dynamo</a>
      <a href="/spin_down" class="btn btn-danger">Spin down that dynamo</a>
    </div>
    <table class="table table-hover">
      <thead>
        <tr>
          <th>Name</th>
          <th>Title</th>
        </tr>
      </thead>
      <tbody>
        <% @nerds.each do |n| %>
          <tr>
            <td><%= n[:name] %></td>
            <td><%= n[:title] %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>
</body>
</html>
