# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'date'
Data_File = "data/data.txt"


helpers do 
  def resource_in_day(resource, day)
    return '' if is_weekend?(day)
    resource.last.find_all{|rs| (Date.parse(rs[:start_date])..Date.parse(rs[:end_date])).include?(day)}.\
      map{|rs| "#{rs[:name]}"}.join("<br/>")
  end

  def color_for_resource_in_day(day, resource = nil)
    is_weekend?(day) ? "style='border: 3px solid'" : ''
  end

  def is_weekend?(day)
    day.saturday? || day.sunday?
  end
end

get '/' do 
  @resources = {}
  File.open(Data_File) do |file|
    project = ''
    file.lines.each do |line|
      line = line.strip
      unless line.empty?
        if line["|"]
          if project == ''
            raise "格式错误"
          else
            department, name, start_date, end_date = line.split("|").map(&:strip)
            @resources[project] << {department:department, name:name, start_date:start_date, end_date:end_date}
          end
        else
          project = line
          if @resources[project].nil?
            @resources[project] = []
          else
            raise "格式错误2"
          end
        end
      end
    end
  end
  
  filter = params[:n].to_s.strip.downcase 
  unless filter.empty?
    @resources.each do |k, v|
      v.delete_if{|rs| rs[:name].downcase != filter }
    end
  end
  
  filter = params[:d].to_s.strip.downcase 
  unless filter.empty?
    @resources.each do |k, v|
      v.delete_if{|rs| rs[:department].downcase != filter }
    end
  end
  erb :index, :layout => :layout
end

get '/edit' do
  File.open(Data_File){|f| @data = f.read}
  erb :edit
end

post '/update' do
  File.open(Data_File,"w"){|f| f.write(params[:data].to_s.strip)}
  redirect "/edit"
end
