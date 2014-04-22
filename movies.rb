require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root,'views')
end

get '/' do
  erb :index
  #Add code here
end


#Add code here 
get '/results' do
   c = PGconn.new(:host => "localhost", :dbname => dbname)
@movies = c.exec_params("SELECT * FROM movie WHERE title = $1;", [params[:movie]])
c.close
erb :search
end

get '/movies/:id' do
 c = PGconn.new(:host => "localhost", :dbname => dbname)
@movies = c.exec_params("SELECT * FROM movie WHERE id = $1;", [params[:id]])

c.close
@title = "title"
@plot = "plot"
@genre = "genre"
@year = "year"
@actors = " actors"
end

get '/movies/new' do
  erb :index

end

get '/movies' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
   # creates a new postgres connection. local connection.
  c.exec_params("INSERT INTO movie (title, year) VALUES ($1, $2)", # executes params and insert our SQL. first argument.
                  [params["title"], params["year"]]) # array of values. second argument.

  c.close
  redirect '/'
end


def dbname
  "movies"
end

def create_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec %q{
  CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title varchar(255),
    year varchar(255),
    plot text,
    genre varchar(255)
  );
  }
  connection.close
end

def drop_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec "DROP TABLE movie;"
  connection.close
end

def seed_movies_table
  movies = [["Glitter", "2001"],
              ["Titanic", "1997"],
              ["Sharknado", "2013"],
              ["Jaws", "1975"]
             ]
 
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  movies.each do |p|
    c.exec_params("INSERT INTO movie (title, year) VALUES ($1, $2);", p)
  end
  c.close
end

