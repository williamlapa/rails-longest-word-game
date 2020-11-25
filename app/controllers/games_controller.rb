class GamesController < ApplicationController
  def new
    # TODO: generate random grid of letters
    @letters = ('A'..'Z').to_a.sample(10)
  end

  require 'open-uri'
  require 'json'

  def score
    # start_time = Time.now
    @attempt = params[:word]
    # end_time = Time.now
    @grid = params[:array].gsub(',', '').gsub('\/', '').gsub('"', '').gsub('[', '').gsub(']', '').gsub(' ', '')
    # raise
    # @score = run_game(attempt, grid, start_time, end_time)
    @score = english_word?(@attempt) && included?(@attempt, @grid)
  end

  # WORD sera a resposta do usuario no form POST
  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, 'well done']
      else
        [0, 'not an english word']
      end
    else
      [0, 'not in the grid']
    end
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    result = { time: end_time - start_time }
    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
    result
  end
end
