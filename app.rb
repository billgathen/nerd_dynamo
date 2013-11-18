require_relative 'lib/nerd_dynamo'
require 'sinatra'

before do
  @nd = NerdDynamo.new
end

get '/' do
  @nerds = @nd.show
  erb :index
end

post '/show' do
  if params['name'].size > 0
    @nerds = @nd.find(params['name'])
  else
    redirect '/'
  end
  erb :index
end

post '/add' do
  if params['name'].size > 0 && params['title'].size > 0
    @nd.add(params['name'], params['title'])
  end

  redirect '/'
end

get '/spin_up' do
  @nd.spin_up
  redirect '/'
end

get '/spin_down' do
  @nd.spin_down
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
      <a href="/"><h1>Nerd Dynamo!</h1></a>
    </div>
    <div class="pull-right">
      <form class="form form-inline" action="/show" method="post">
        <label for="name">Find By Name</label>
        <input type="text" name="name" />
        <a href="/spin_up" class="btn btn-success">Spin up that dynamo</a>
        <a href="/spin_down" class="btn btn-danger">Spin down that dynamo</a>
      </form>
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
    <form class="form form-horizontal" action="/add" method="post">
      <form-group>
        <label for="name" class="col-xs-2 control-label">Name</label>
        <div class="col-xs-10">
          <input class="form-control" type="text" id="name" name="name" />
        </div>
      </form-group>
      <form-group>
        <label for="title" class="col-xs-2 control-label">Title</label>
        <div class="col-xs-10">
          <input class="form-control" type="text" id="title" name="title" />
        </div>
      </form-group>
      <form-group>
        <div class="col-xs-offset-2 col-xs-10">
          <input class="form-control btn btn-default" type="submit" value="Add Nerd" />
        </div>
      </form-group>
    </form>
  </div>
</body>
</html>
