require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split(/\n\n/).each_with_index.map do |line, index| 
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def each_chapter(&block)
    @contents.each_with_index do |name, index|
      number = index + 1
      contents = File.read("data/chp#{number}.txt")
      yield number, name, contents
    end
  end

  def chapters_matching(query)
    results = []
    return results unless query

    each_chapter do |number, name, contents|
      matches = {}
      contents.split(/\n\n/).each_with_index do |paragraph, index|
        matches[index] = paragraph if paragraph.include?(query)
      end
      results << {number: number, name: name, paragraphs: matches} if matches.any?
    end

    results
  end

  def bold_search_term(text, query)
    text.gsub(query, %(<strong>#{query}</strong>))
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  @number = params[:number]
  @chapter_name = @contents[@number.to_i - 1]
  @title = "Chapter #{@number}: #{@chapter_name}"
  @chapter = in_paragraphs(File.read("data/chp#{@number}.txt"))
  erb :chapter
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end


not_found do
  redirect "/"
end
