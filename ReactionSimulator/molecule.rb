require 'ruby_extensions'
require 'molecule_data'

class Molecule  
    
    attr_reader :formula, :jess, :name, :cas, :weight, :phase, :gibbs_formation

    def initialize(data)
        @formula = data[:formula] # Simple formula
        @jess = data[:jess] # JESS database name
        @name = data[:name] # General name
        @cas = data[:cas] # CAS registry number
        @weight = data[:weight] # Molecular weight
        @phase = data[:phase] # :s, :l, :g, :aq  
        @gibbs_formation = data[:G_f] # in STP  J mol-1.       G(p,T) = H - TS 
        @enthalpy_formation = data[:H_f] # in STP   J mol-1
        @entropy = data[:s] # J mol-1 K-1
        self.freeze
    end
    
    def formula_phase
        "#{formula}(#{phase})"
    end
           
    def self.find(properties)
        if find_all(properties).length == 1
            find_all(properties).first
        elsif find_all(properties).length > 1
            raise "More than one result with search #{properties}"
        else
            raise "Molecule not found for #{properties}"
        end
    end
    
    def self.find_all(prop)
        if prop.is_a?(String) # eg. 'CH3COOH(l)'
            all_molecules.select { |molecule| molecule.formula_phase == prop.to_str } 
        elsif prop.is_a?(Hash) # eg. { :formula => 'CH3COOH', :phase => :l }
            all_molecules.select { |mol| prop.all? { |p,value| mol.send(p) == value } }
        else
            raise "Cannot search molecules with #{prop.class}, need string or Hash"
        end
    end
    
    def self.all_molecules
        @all_molecules ||= MOLECULE_DATA.map { |data| Molecule.new(data) }
    end

end
