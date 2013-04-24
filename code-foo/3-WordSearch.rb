module CodeFoo # Keep the general namespace unclogged

  text = IO.read("word-search.txt") # Read the word-search.txt file
  search, words = *text.split("Words to find:") # Split between the actual wordsearch, and the answers
  Search = search.delete("\t").split("\n").reject do |a| a.empty? end # Clean up the search by eliminating tabs, splitting between the different lines, and eliminating empty lines
  
  Words = words.split("\n").reject do |a| a.empty? end.collect do |a| a.downcase.delete(" ") end # Clean up the answers bt splitting lines, eliminating empty lines, downcasing all the words and getting rid of spaces
  
  class FoundWord < Struct.new(:word, :start_point, :end_point) # Simple construct for keeping found words and their data
  end
  
  class WordSearch # Hold our search and methods for solving
    
    DIRECTIONS = [[0, 1], [0, -1], [-1, 0], [-1, -1], [-1, 1], [1, 1], [1, -1], [1, 0]] # All directions a word could be found
    
    attr_reader :found_words, :unfound_words # Some attributes for reading the results

    # Set the default attribute values. Provide a wordsearch in an array format with each line separated
    def initialize(search)
      @search = search
      @found_words = []
      @unfound_words = []
    end
    
    # Solve the wordsearch provided with the words to find
    def solve_wordsearch(words)
      found_words = []
      words.each do |word| # Go through every word
        @search.each_with_index do |line, index| # Go through every line
          i = 0 # Keep an index for the following iterations
          indexes = [] # Indexes of the first letter in the word found in the line
          line.each_char do |a| # Go through every character in the line
            indexes << [i, index] if a == word[0] # Add an index for the letter if the letter if the first letter of the word
            i += 1 # Add to the index keeper
          end
          indexes.each do |windex| # For all the indexes we found
            DIRECTIONS.each do |a| # Check every direction
              if (end_point = find_word_chain(word, windex.dup, a)) # If the word is found by checking the starting point of the first letter continuing in the given direction
                @found_words << FoundWord.new(word, windex, end_point) # Add that word to the found words variable wth it's start and ending points
                break # Stop checking directions
              end
            end
          end
        end
      end
      @unfound_words = words - @found_words.collect do |a| a.word end # Store the unfound words
    end
    
    def find_word_chain(word, start_point, directions)
      letters = word.split(//i) # Get the word's individual letters
      length = @search[0].length - 1 # Avoid additional arithmetic by caching the length of every line
      until letters.empty? # Keep going until we found all the letters
        return false unless start_point[0].between?(0, length) && start_point[1].between?(0, @search.size - 1) # End the search if the points go out of bounds
        if @search[start_point[1]][start_point[0]] == letters.shift # If the wordsearch has the next letter at the designated point
          start_point[0] += directions[0] # Add to the next x coordinate based on the direction given
          start_point[1] += directions[1] # Add to the next y coordinate based on the direction given
        else
          return false # If the next point is not the next letter, end the search
        end
      end
      start_point[0] -= directions[0] # Move back a point for proper ending point
      start_point[1] -= directions[1] # Move back a point for proper ending point
      start_point # Return the edited starting point as the ending point
    end
  end
end

# Sample code I used to test all the functions below
__END__
f = CodeFoo::WordSearch.new(CodeFoo::Search)
f.solve_wordsearch(CodeFoo::Words)
f.found_words.each do |a|
  puts a
end
p f.unfound_words