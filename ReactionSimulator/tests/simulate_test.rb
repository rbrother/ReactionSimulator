require 'test/unit'
require 'molecule'
require 'reagent'
require 'reaction'
require 'Simulate'
require 'solver'

class MoleculeTest < Test::Unit::TestCase

    def test_find_molecule
        mol = Molecule.find('CH3COOH(l)')
        assert (mol != nil), "CH3COOH(l) not found"
        assert_equal -396.46e3, mol.gibbs_formation
    
        mol = Molecule.find( :formula => 'CH3COOH', :phase => :l )
        assert (mol != nil), "CH3COOH(l) not found 2"
        assert_equal -396.46e3, mol.gibbs_formation
    end

end

class SimpleReactionBalanceTest < Test::Unit::TestCase

    def test_water_dissociation
        s = Simulation.new( 
            { :name => 'H2O(l)', :conc => C_WATER },
            { :name => 'H+(aq)', :conc => 1e-5 },
            { :name => 'OH-(aq)', :conc => 1e-5 }
        )
        assert_equal 3, s.reagents.length
        assert_in_delta C_WATER, s.conc('H2O(l)'), 0.1
        assert_equal 'H2O', s.reagent('H2O(l)').formula
        assert_raise(IndexError) { s.reagent('abc') }
        assert_equal 1, s.reactions.length
        reaction = s.reactions.first
        assert_equal 1, reaction.term('OH-(aq)').count
        assert_equal 1e-5, reaction.term('OH-(aq)').k_factor, "reaction.term('OH-(aq)').k_factor"
        
        assert_in_delta 1.8e-12, reaction.k_calc, 1e-14, "reaction.k_calc"
        assert_in_delta -1e-5, reaction.coordinate_delta_min, 1e-6
        assert_in_delta 1000.0/18, reaction.coordinate_delta_max, 0.1
        
        s.simulate_equilibrium()
        assert_in_delta 1.0e-7, s.conc('H+(aq)'), 1.0e-8
        assert_in_delta 1.0e-7, s.conc('OH-(aq)'), 1.0e-8
    end

    def test_acid_dissociation
        s = Simulation.new(
            { :name => 'H2O(l)', :conc => 1000.0/18 },
            { :name => 'H+(aq)', :conc => 1e-5 },
            { :name => 'OH-(aq)', :conc => 1e-5 },
            { :name => 'CH3COOH(l)', :conc => 0.5 },
            { :name => 'CH3COO-(aq)', :conc => 0.0 }
        )
        assert_equal 2, s.reactions.length
        s.simulate_equilibrium()
        # Asserting from Mathematica results. Except for [OH-] for which
        # our simplified Mathematica gives 3.36364e-12, very slightly differing
        assert_in_delta 0.00297297, s.reagent('H+(aq)').conc, 1e-5
        assert_in_delta 0.00297297, s.reagent('CH3COO-(aq)').conc, 1e-5
        assert_in_delta 3.40046e-12, s.reagent('OH-(aq)').conc, 1e-13
        assert_in_delta 0.497027, s.reagent('CH3COOH(l)').conc, 0.01
    end

    def test_ammonia
        s = Simulation.new(
            { :name => 'H2O(l)', :conc => 1000.0/18 },
            { :name => 'H+(aq)', :conc => 0.0 },
            { :name => 'OH-(aq)', :conc => 0.0 },
            { :name => 'NH4+(aq)', :conc => 0.2 },
            { :name => 'NH3(aq)', :conc => 0.0 }
        )
        assert_equal 2, s.reactions.length
        s.simulate_equilibrium()
    end
    
    def test_acid_ammonia
        # TODO: Model NH4Cl dissociation as well
        # NH4+Cl- + CH3COOH + NH4+ + Cl- + CH3COO- + H20 + OH- + H+ + CH3COONH4 + NH3
        # NH4+Cl- 0.2 M
        # CH3COOH  0.3 M
        # Note: We do not account CH3COONH4 here, could not find data for K. TODO: CHeck
        s = Simulation.new(
            { :name => 'H2O(l)', :conc => C_WATER },
            { :name => 'H+(aq)', :conc => 0.0 },
            { :name => 'OH-(aq)', :conc => 0.0 },
            { :name => 'CH3COOH(l)', :conc => 0.3 },
            { :name => 'CH3COO-(aq)', :conc => 0.0 },
            { :name => 'NH4+(aq)', :conc => 0.2 },
            { :name => 'NH3(aq)', :conc => 0.0 }
        )
        assert_equal 3, s.reactions.length
        s.simulate_equilibrium()
    end

end

class TimeDependentReactionTest < Test::Unit::TestCase

    def test_water_dissociation
        s = Simulation.new( 
            { :name => 'H2O(l)', :conc => C_WATER },
            { :name => 'H+(aq)', :conc => 1e-5 },
            { :name => 'OH-(aq)', :conc => 1e-5 }
        )
        s.simulate_time(1.0) # seconds to calculate forwards
        assert_in_delta 1.0e-7, s.conc('H+(aq)'), 1.0e-8
        assert_in_delta 1.0e-7, s.conc('OH-(aq)'), 1.0e-8        
    end

end