# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'erb'

DATA_FILE = './memo_app.json'

def load_memo(id = nil)
  memos = []

  if File.exist?(DATA_FILE)
    File.open(DATA_FILE) do |file|
      memos = JSON.parse(file.read)
    end
  end

  # idが整数で無い場合は不正なデータとして除外します。
  memos.select! { |memo| memo['id'].instance_of?(Integer) }

  if id.nil?
    memos
  else
    memos.detect { |memo| memo['id'] == id }
  end
end

def save_memo(memos)
  File.open(DATA_FILE, 'w') do |file|
    JSON.dump(memos, file)
  end
end

def make_next_id(memos)
  return 0 if memos.empty?

  memos.map { |memo| memo['id'] }.max + 1
end

get '/' do
  @title = 'All memos'

  @memos = load_memo

  erb :index
end

get '/memos/new' do
  @title = 'New memo'

  @error_message = 'Titleを入力してください。' if params['error'] == 'title'

  erb :new
end

post '/memos' do
  if params['title'].empty?
    redirect to('/memos/new?error=title')
  else
    memos = load_memo
    next_id = make_next_id(memos)

    title = params['title']
    description = params['description']
    memos << { 'id' => next_id, 'title' => title, 'description' => description }

    save_memo(memos)

    redirect '/'
  end
end

get '/memos/:id' do
  @title = 'Show memo'

  @memo = load_memo(params['id'].to_i)

  erb :show
end

get '/memos/:id/edit' do
  @title = 'Edit memo'

  @error_message = 'Titleを入力してください。' if params['error'] == 'title'

  @memo = load_memo(params['id'].to_i)

  erb :edit
end

patch '/memos/:id' do
  if params['title'].empty?
    redirect to("/memos/#{params['id']}/edit?error=title")
  else
    memos = load_memo

    index = memos.index { |memo| memo['id'] == params['id'].to_i }
    memos[index]['title'] = params['title']
    memos[index]['description'] = params['description']

    save_memo(memos)

    redirect '/'
  end
end

delete '/memos/:id' do
  memos = load_memo

  memos.reject! { |memo| memo['id'] == params['id'].to_i }

  save_memo(memos)

  redirect '/'
end
