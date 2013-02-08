require 'reaction'

class Simulation

    attr_reader :reagents, :reactions

    def initialize(*molecules) # list of { :name => 'H2O(l)', :conc => 55.55 }
        @reagents = molecules.map { |m| [ m[:name], Reagent.new(m[:name],m[:conc]) ] }.to_hash       
        @reactions = Reaction.find_reactions( reagents )
    end
        
    def report
        puts "======= Concentrations ========"
        @reagents.values.map { |r| r.to_s }
    end
    
    def reagent(name)
        @reagents.fetch(name)
    end
    
    def conc(name)
        reagent(name).conc
    end

    def simulate_equilibrium(verbose = false)
        # Currently we individually optimise single equilibrium equations one at a time,
        # then repeat over the set of equations several times until all are converged.
        # This is clearly not optimal but seems to suffice and converge globally ok for 
        # cases tested so far. A more optimal approach would optimize all independent
        # variables in one multi-dimensional multi-variable optimisation. TODO: Check
        10.times do |n|
            puts "\n================= ROUND #{n} =================" if verbose
            @reactions.each { |reaction| reaction.simulate_equilibrium( verbose ) }
            if @reactions.all? { |r| r.converged? }
                puts "**** ALL CONVERGED ****" if verbose
                return true # converged
            end
            puts report if verbose
        end
        puts "!!!!!!!!!!!!!!!!! FAILS TO CONVERGE !!!!!!!!!!!!!!!!!!!!" if verbose
        false
    end
    
    def simulate_time(duration)
        @reactions.each { |reaction| reaction.simulate_time(duration) }
    end    

end

