module CodeFoo # Keep the main namespace free of unneeded clutter by using a module
  class HighScore # Simple class to hold each individual score data
    
    attr_reader :score, :name # Just have a score and a name, though a time submitted may also be useful for same-scored scores
    
    # Just set the attributes at initialization
    def initialize(score, name)
      @score = score.to_f # The prompt said score should be a float, so for consistency we force it.
      @name = name
    end
    
    # Define the <=> method to say a higher score comes before a lower score during .sort!
    def <=>(score)
      score.score <=> @score
    end
  end
  
  class LeaderBoard # Hold all the scores and allow sorting. Could have used a simple array however having exra methods here is more useful
    
    attr_reader :scores # Atrribute for all the scores
    
    # Setting scores for a simple array, and a bool to determine if scores need sorting
    def initialize
      @scores = []
      @need_sort = false
    end
    
    # Add a score, which can be an already made CodeFoo::HighScore, or the score + name
    def add_score(score, name = nil)
      @scores << (score.is_a?(CodeFoo::HighScore) ? score : CodeFoo::HighScore.new(score, name))
      @need_sort = true # Tell the leaderboard that the scores need sorting
    end
    
    # Couple of convinience methods for adding scores
    alias push add_score
    alias << add_score # This one only works if adding a prebuilt CodeFoo::HighScore
    
    # Remove a score for some reason, must pass the actual CodeFoo::HighScore object
    def remove_score(score)
      @scores.delete(score) # Wouldn't require a resorting after deleting since there'd be no change
    end
    
    def partition(left, right, pivot_index)
      pivot = @scores[pivot_index].score # Our partition pivot point is the score of the given pivot index
      @scores[pivot_index], @scores[right] = @scores[right], @scores[pivot_index] # Switch the pivot point with the ending point
      si = left # Set si to the base starting point, which will be added to later based on how many indexes have been searched
      for i in left...right # For every index between the beginning and ending point, not including the ending point
        if @scores[i].score > pivot # If the score of the object at the index of the scores is higher than the pivot point
          @scores[i], @scores[si] = @scores[si], @scores[i] # Swap the base point plus number of indexes with the current index point
          si += 1 # Add 1 to the base starting point
        end
      end
      @scores[si], @scores[right] = @scores[si], @scores[right] # Swap the ending point with the base point that was added to every inde search
      si # Return the base point that was added to for every index search as the new pivot point
    end
    
    # Sorting the array with a quicksort algorithm, a recursive sorting algorithm
    # This algorithm scales as high as you need it to, however this implementation sacrifices some speed in favor of memory management.
    # This implementation only uses the existing scores array and does not create a second one.
    # Speed can be raised, albeit not by much, by sorting with a secondary array. However this can create massive memory consumption.
    def sort_scores(left, right)
      return @scores if @scores.size <= 1 # Don't sort if I don't need to
      if left < right
        pivot = left + (right - left) / 2 # Take a more reasonable pivot point using a modified middle
        new_pivot = partition(left, right, pivot) # Grab a new pivot point by partitioning the array
        sort_scores(left, new_pivot - 1) # Resort with the base starting point and the new pivot point
        sort_scores(new_pivot + 1, right) # Resort with the new pivot point and the base ending point
      end
    end
    
    # Get the top(n) scores in an array
    def top(range)
      if @need_sort # Only sort if a new score has been added
        #sort_scores(0, @scores.size - 1) # The prompt stated that I had to write an algorithm, so despite ruby having a .sort! method, I have also included a different implementation
        @scores.sort! # Ruby's basic sorting method
        # Using Ruby's base sort! is much much faster than the implementation of quicksort.
        @need_sort = false
      end
      @scores[0...range] # Return the scores from the top one until the given range
    end
  end
end

# Sample code I used to test all the functions below
__END__
leaderboard = CodeFoo::LeaderBoard.new # Construct empty leaderboards
50000.times do |i|
  leaderboard.push(rand(100), "IGN #{i}") # Add 500000 new random scores between 0 and 99
end
leaderboard.top(10).each do |score|
  puts "#{score.name}: #{score.score}" # Print the top 10 scores
end