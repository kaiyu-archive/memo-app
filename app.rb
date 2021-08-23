# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'erb'
require 'pg'

class Database
  def initialize
    @connection = connect_db
    initialize_db
  end

  def select_memos
    @connection.exec('SELECT * FROM memo ORDER BY id;')
  end

  def select_memo(id)
    @connection.exec_params('SELECT * FROM memo WHERE id = $1;', [id]).first
  end

  def insert_memo(title, description)
    @connection.exec_params('INSERT INTO memo(title, description) values($1, $2);', [title, description])
  end

  def update_memo(id, title, description)
    @connection.exec_params('UPDATE memo SET title = $1, description = $2 WHERE id = $3;', [title, description, id])
  end

  def delete_memo(id)
    @connection.exec_params('DELETE FROM memo WHERE id = $1;', [id])
  end

  private

  DB_NAME = 'memo_app'

  def connect_db
    PG.connect(dbname: DB_NAME)
  end

  def exists_table?
    result = @connection.exec("SELECT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'memo');").first
    result['exists'] == 't'
  end

  def create_table
    @connection.exec('CREATE TABLE memo(id serial NOT NULL PRIMARY KEY, title varchar(100) NOT NULL, description text);')
  end

  def initialize_db
    create_table unless exists_table?
  end
end

before do
  @db = Database.new
end

ERROR_BLANK_TITLE = 'Titleを入力してください。'

get '/' do
  @title = 'All memos'

  @memos = @db.select_memos

  erb :index
end

get '/memos/new' do
  @title = 'New memo'

  @error_message = ERROR_BLANK_TITLE if params['error'] == 'title'

  erb :new
end

post '/memos' do
  if params['title'].empty?
    redirect to('/memos/new?error=title')
  else
    title = params['title']
    description = params['description']
    @db.insert_memo(title, description)

    redirect '/'
  end
end

get '/memos/:id' do
  @title = 'Show memo'

  @memo = @db.select_memo(params['id'].to_i)

  erb :show
end

get '/memos/:id/edit' do
  @title = 'Edit memo'

  @error_message = ERROR_BLANK_TITLE if params['error'] == 'title'

  @memo = @db.select_memo(params['id'].to_i)

  erb :edit
end

patch '/memos/:id' do
  if params['title'].empty?
    redirect to("/memos/#{params['id']}/edit?error=title")
  else
    id = params['id'].to_i
    title = params['title']
    description = params['description']
    @db.update_memo(id, title, description)

    redirect '/'
  end
end

delete '/memos/:id' do
  @db.delete_memo(params['id'].to_i)

  redirect '/'
end

not_found do
  erb :not_found
end
