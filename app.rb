# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'erb'
require 'pg'

DB_NAME = 'memo_app'

def connect_db
  PG.connect(dbname: DB_NAME)
end

def select_memo(db, id = nil)
  result = db.exec("SELECT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'memo');").first
  db.exec('CREATE TABLE memo(id serial NOT NULL PRIMARY KEY, title varchar(100) NOT NULL, description text);') if result['exists'] == 'f'

  if id.nil?
    db.exec('SELECT * FROM memo ORDER BY id;')
  else
    db.exec_params('SELECT * FROM memo WHERE id = $1;', [id]).first
  end
end

def insert_memo(db, title, description)
  db.exec_params('INSERT INTO memo(title, description) values($1, $2);', [title, description])
end

def update_memo(db, id, title, description)
  db.exec_params('UPDATE memo SET title = $1, description = $2 WHERE id = $3;', [title, description, id])
end

def delete_memo(db, id)
  db.exec_params('DELETE FROM memo WHERE id = $1;', [id])
end

before do
  @db = connect_db
end

ERROR_BLANK_TITLE = 'Titleを入力してください。'

get '/' do
  @title = 'All memos'

  @memos = select_memo(@db)

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
    insert_memo(@db, title, description)

    redirect '/'
  end
end

get '/memos/:id' do
  @title = 'Show memo'

  @memo = select_memo(@db, params['id'].to_i)

  erb :show
end

get '/memos/:id/edit' do
  @title = 'Edit memo'

  @error_message = ERROR_BLANK_TITLE if params['error'] == 'title'

  @memo = select_memo(@db, params['id'].to_i)

  erb :edit
end

patch '/memos/:id' do
  if params['title'].empty?
    redirect to("/memos/#{params['id']}/edit?error=title")
  else
    id = params['id'].to_i
    title = params['title']
    description = params['description']
    update_memo(@db, id, title, description)

    redirect '/'
  end
end

delete '/memos/:id' do
  delete_memo(@db, params['id'].to_i)

  redirect '/'
end

not_found do
  erb :not_found
end
