require 'ruby_extensions'
require 'reaction_data'
require 'reaction_term'

class Reaction

    def initialize(data, reagents)
        @terms = [:left, :right].map do |side|
            # TODO: Nyt reaktiota ei oteta mukaan, jos ei löydy jotain reakenssia.
            # Pitäisi ottaa mukaan jos löytyy nollasta poikkeavalla konsentraatiolla
            # oikean *tai* vasemman puolen reagenssit (ja lisätä silloin dynaamisesti
            # toisen puolen reagenssit nolla-konsentraatiolla).
            # Itse asiassa dynaamisesti simulaation aikana pitäisi simulaation lisätä
            # reagensseja ja reaktioita, jos simulaatio tuottaa uusia reagensseja, 
            # uudet reagenssit uusia reaktiota ja ne puolestaan taas uusia reagensseja...            
            data[side].map do |count,name| 
                ReactionTerm.new(side, count, (reagents[name] || throw(:reagent_not_found)) )
            end
        end
        @terms.flatten!
        @celcius = data[:celsius]
        @k = data[:K]
        @k_forward = 1000.0 # ad hoc number in absense of given rates
        @k_backward = @k_forward / @k
    end
    
    def to_s
        one_side_terms(:left).map { |t| t.to_s }.join(' + ') + " <---> " +
        one_side_terms(:right).map { |t| t.to_s }.join(' + ')
    end    
                          
    def term(reagent_name)
        @terms.find { |term| term.name == reagent_name }
    end 
        
    def one_side_terms(side)
        @terms.select { |term| term.side == side }
    end
       
    # Reaction coordinate be if reaction would go completely to left
    def coordinate_delta_min
        one_side_terms(:right).map { |term| -term.conc / term.count }.max            
    end

    # Reaction coordinate be if reaction would go completely to right
    def coordinate_delta_max
        one_side_terms(:left).map { |term| term.conc / term.count }.min
    end
    
    def k_calc( terms = @terms, coordinate_delta = 0.0 )
        one_side_terms(:right).map { |term| term.k_factor(coordinate_delta) }.product /
        one_side_terms(:left).map { |term| term.k_factor(coordinate_delta) }.product
    end
    
    def k_equilibrium
        @k
    end
    
    def converged?
        ((k_calc / k_equilibrium) - 1.0).abs < 0.01
    end
        
    def simulate_equilibrium(verbose = false)
        puts "----- Balancing reaction #{self.to_s} -----" if verbose
        @xs = [ 0, coordinate_delta_max*1e-3 ] unless @xs
        100.times do |n|
            if converged?
                puts "CONVERGED: #{@terms}" if verbose
                break
            end
            puts "#{n}: #{@terms}" if verbose
            func = proc { |coord| (k_calc( @terms, coord ) - k_equilibrium) ** 2 } # to minimize
            x_valid_range = Range.new(coordinate_delta_min, coordinate_delta_max)
            while @xs.first == 0.0
                @xs = Simplex.step( func, @xs, x_valid_range, verbose )
            end
            # Perform concentration shift
            @terms.each { |term| term.shift!(@xs.first) }
            dx = @xs.last - @xs.first            
            # Perform equivalent x-guess shift
            @xs = [ 0.0, dx ]
        end                
    end
    
    def simulate_time(duration)
        coordinate_delta = 
            @k_forward * one_side_terms(:left).map { |term| term.k_factor }.product -
            @k_backward * one_side_terms(:right).map { |term| term.k_factor }.product
        @terms.each { |term| term.shift!( coordinate_delta * duration ) }
    end
           
    def self.find_reactions( reagents )
        reactions = []        
        REACTION_DATA.each do |rdata|
            catch(:reagent_not_found) { reactions << Reaction.new(rdata, reagents) }
        end
        reactions
    end

end 
