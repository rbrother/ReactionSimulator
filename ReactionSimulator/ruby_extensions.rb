class Array

    def to_hash
        Hash[ *self.flatten ]
    end
    
    def product
        inject { |a,b| a*b }
    end
   
end

class Hash

    def map_values
        self.map { |key,value| [key, yield(value)] }.to_hash
    end
    
end