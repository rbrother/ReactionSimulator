require 'ruby_extensions'

# The "Nelder–Mead method" or "downhill simplex method" or "amoeba method"
# http://en.wikipedia.org/wiki/Nelder%E2%80%93Mead_method
module Simplex
      
    def self.step(func, xs, x_limits, verbose = false)
        raise "#{xs} not in limits #{x_limits}" if xs.any? { |x| !x_limits.include?(x) }
        print "Simplex: #{xs.inspect}" if verbose
        fs = xs.map { |x| func[x]}
        x_good, x_bad = fs.first < fs.last ? xs : xs.reverse        
        x_all = { :good => x_good, :bad => x_bad, :reflect => 2 * x_good - x_bad,
               :extend => 3 * x_good - 2 * x_bad, :contract => 0.5 * (x_good + x_bad) }
        x_all = x_all.select { |name,x| x_limits.include?(x) } # take only from valid area
        f_all = x_all.map_values { |x| func[x] }
        
        if x_all[:reflect] && f_all[:reflect] < f_all[:bad]
            if x_all[:extend] && f_all[:reflect] < f_all[:good] && f_all[:extend] < f_all[:reflect]
                puts " <extend>" if verbose
                [ x_good, x_all[:extend] ]
            else
                puts " <reflect>" if verbose
                [ x_good, x_all[:reflect] ]
            end
        else # reflection fails: contract
            puts " <contract>" if verbose
            [ x_good, x_all[:contract] ]
        end        
    end
                      
end
