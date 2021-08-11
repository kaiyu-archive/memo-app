# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'erb'

def load_memo(id = nil)
  memos = []

  if File.exist?('./memo_app.json')
    File.open('./memo_app.json') do |file|
      memos = JSON.parse(file.read)
    end
  end

  if id.nil?
    memos
  else
    memos.detect { |memo| memo['id'] == id }
  end
end

def save_memo(memos)
  File.open('./memo_app.json', 'w') do |file|
    JSON.dump(memos, file)
  end
end

def make_next_id(memos)
  return 0 if memos.empty?

  memos.map { |memo| memo['id'] }.max + 1
end

get '/' do
  @title = 'all memos'

  @memos = load_memo

  erb :index
end

get '/memos/new' do
  @title = 'new memo'

  @error_message = 'Titleを入力してください。' if params['error'] == 'title'

  erb :new
end

post '/memos' do
  if params['title'].empty?
    redirect to('/memos/new?error=title')
  else
    memos = load_memo
    next_id = make_next_id(memos)

    title = ERB::Util.html_escape(params['title'])
    description = ERB::Util.html_escape(params['description'])
    memos << { 'id' => next_id, 'title' => title, 'description' => description }

    save_memo(memos)

    redirect '/'
  end
end

get '/memos/:id/show' do
  @title = 'show memo'

  @memo = load_memo(params['id'].to_i)

  erb :show
end

get '/memos/:id/edit' do
  @title = 'edit memo'

  @error_message = 'Titleを入力してください。' if params['error'] == 'title'

  @memo = load_memo(params['id'].to_i)

  erb :edit
end

post '/memos/:id' do
  if params['title'].empty?
    redirect to("/memos/#{params['id']}/edit?error=title")
  else
    memos = load_memo

    index = memos.index { |memo| memo['id'] == params['id'].to_i }
    memos[index]['title'] = ERB::Util.html_escape(params['title'])
    memos[index]['description'] = ERB::Util.html_escape(params['description'])

    save_memo(memos)

    redirect '/'
  end
end

get '/memos/:id/delete' do
  memos = load_memo

  memos.reject! { |memo| memo['id'] == params['id'].to_i }

  save_memo(memos)

  redirect '/'
end
