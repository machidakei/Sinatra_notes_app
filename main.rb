# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'csv'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  File.open('notes.csv', 'r') do |f|
    @notes = f.read.split("\n")
  end
  erb :notes
end

get '/notes' do
  File.open('notes.csv', 'r') do |f|
    @notes = f.read.split("\n")
  end
  erb :notes
end

get '/new' do
  erb :new
end

post '/notes' do
  @id = h(params[:id]).to_s
  @title = h(params[:title]).to_s
  @content = h(params[:content]).to_s
  File.open('notes.csv', 'a') do |f|
    f.puts("#{@id},#{@title},#{@content}")
  end

  File.open('notes.csv', 'r') do |f|
    @notes = f.read.split("\n")
  end

  erb :notes
end

get '/show/:id' do
  notes = CSV.read('notes.csv')
  @post = notes.find { |note| note[0] == h(params[:id]).to_s }
  erb :show
end

get '/edit/:id' do
  notes = CSV.read('notes.csv')
  @post = notes.find { |note| note[0] == h(params[:id]).to_s }
  erb :edit
end

post '/update/:id' do
  notes = CSV.read('notes.csv')
  index = notes.find_index { |note| note[0] == h(params[:id]).to_s }
  notes[index][1] = h(params[:title]).to_s
  notes[index][2] = h(params[:content]).to_s

  CSV.open('notes.csv', 'w') do |csv|
    notes.each do |note|
      csv << note
    end
  end

  redirect "/show/#{h(params[:id])}"
end

get '/destroy/:id' do
  notes = CSV.read('notes.csv')
  notes.delete_if { |note| note[0] == params['id'] }
  CSV.open('notes.csv', 'w') do |csv|
    notes.each do |note|
      csv << note
    end
  end

  redirect '/'
end
