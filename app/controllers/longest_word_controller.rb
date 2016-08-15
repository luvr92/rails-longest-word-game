class LongestWordController < ApplicationController
  def game
    letters = generate_grid
    @grid = letters.join(" ")
  end

  def score
    start = Time.parse(params[:starting_time])
    the_end = Time.now
    grid = params[:grid].split(" ")
    @score = run_game(params[:guess], grid, start, the_end)
  end

  def generate_grid
  # TODO: generate random grid of letters
    Array.new(15).map { |letter| letter = ("A".."Z").to_a.sample.upcase }
  end

  def run_game(attempt, grid, start_time, end_time)
   # TODO: runs the game and return detailed hash of result
   result = {}
   result[:time] = time_taken(start_time, end_time)
   result[:translation] = translate_word(attempt)
   result[:score] = compute_score(result[:time], attempt)
   if !attempt_in_grid?(attempt, grid)
     result[:message] = "not in grid"
   elsif !word_existence?(attempt)
     result[:message] = "not an english word"
   else
     result[:message] = "well done"
   end
   return result
  end

  def translate_word(attempt)
   url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}";
   word_JSON = JSON.parse(open(url).read)
   if word_JSON["term0"]
     word_JSON["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
   else
     "empty string"
   end
  end

  def time_taken(start_time, end_time)
   end_time - start_time
  end

  def attempt_in_grid?(attempt, grid)
    (attempt.upcase.split("") - grid).empty?
  end

  # p attempt_in_grid?("London", ["o", "n", "n", "o", "d", "l", "t", "q", "w"])

  def word_existence?(attempt)
    #check if attempt exists in our given API
    serialized_words = open("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}").read
    words = JSON.parse(serialized_words)
    words["Error"] == "NoTranslation" ? false : true
  end

  def compute_score(time_taken, attempt)
   attempt.length * 1/time_taken
  end
end
