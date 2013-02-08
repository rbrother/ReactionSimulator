require 'molecule'

class Reagent
    
    attr_accessor :conc
    
    def initialize(molecule, conc)
        @molecule = molecule.is_a?(String) ? Molecule.find( molecule ) : molecule
        @conc = conc
    end
    
    def name
        @molecule.formula_phase
    end
    
    def method_missing(name, *pars)
        @molecule.send(name, *pars)
    end
    
    def shift!( conc_delta )
        @conc += conc_delta
    end
    
    def to_s
        "[#{name}] = #{conc}"
    end
    
end
