require 'reagent'

class ReactionTerm

    attr_reader :side, :count       
        
    def initialize(side, count, reagent)
        @side = side
        @count = count
        @reagent = reagent
        self.freeze
    end    
    
    # Allow reaction term behave as a reagent
    def method_missing(func, *params)
        @reagent.send(func, *params)        
    end
    
    def left_side?; side == :left; end
    
    def k_factor(coordinate_delta = 0.0)
        (conc + conc_shift( coordinate_delta )) ** count
    end
       
    def shift!( coordinate_delta )
        @reagent.shift!( conc_shift(coordinate_delta) )
    end
        
    def conc_shift( coordinate_delta )
        coordinate_delta * count * (left_side? ? -1 : 1 )
    end
    
    def to_s
        @reagent.to_s
    end
    
    def inspect; to_s; end
    
end
