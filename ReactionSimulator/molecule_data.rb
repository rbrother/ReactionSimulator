require 'physical_constants' 

# We can get G(formation) for the Molecule as well dG(formation) = -RT lnK.
# JESS has formation reactions and "shortened method for formation reactions (when a Molecule 
# is formed just from its elements)." by reaction shortcut "= <Molecule>"
# From G(formation) we can then calculate dG reaction and hence lgK -> K for *all* reactions.
# (perhaps we can allow lgK to be specified explicitly for reaction or calculated from G:s...?)    
#
# In values, give units like: G_f => -369.31 * KJ  (these are converted to SI units with physical_constants)
# Strictly SI-values need no units but can still be given for clarity.
#
# Infor on extrapolation of dH and dG to different temperatures based on parametrised equations:
# http://en.wikipedia.org/wiki/Thermodynamic_databases_for_pure_substances
#
# http://www.thermart.net/ FREED is a spreadsheet-based Free Energy and Enthalpy database with over 2400 Species.
#
# http://thermodata.online.fr/anglais.html (commercial database and equilibrium calculator)
#
# http://mtdatasoftware.tech.officelive.com/default.htm (MTDATA – Phase Diagram Software from the National Physical Laboratory)

MOLECULE_DATA = 
[   # http://webbook.nist.gov/cgi/cbook.cgi?ID=C12125029&Units=SI
    # 0.5<Cl2(g)> + 2<H2(g)> + 0.5<N2(g)> = H+1_NH3_Cl-1
    # 1 t=25 I=0 Inf. Dilution  dG -50.3(0.05SD) Wgt=5 ENS[802]
    # 2 t=25 I=0 Inf. Dilution  dH -71.6(0.1SD) Wgt=5 ENS[802] = -299.6 // NIST H_f = -314.55 kJ/mol !!?
    {   :formula => 'NH4Cl', :name => 'Ammonium chloride', :jess => 'H+1_NH3_Cl-1', :phase => :s,  
        :G_f => -50.3*KCAL/MOL, :H_f => -314.55*KJ/MOL, :S => 94.85, :weight => 53.491 },  
    # http://webbook.nist.gov/cgi/inchi/InChI%3D1S/H3N/h1H3/p%2B1
    { :formula => 'NH4+', :jess => 'H+1_NH3', :phase => :aq, :name => 'Ammonium ion', :cas => '14798-03-9', :weight => 18.0385 },
    { :formula => 'Cl-', :jess => 'Cl-1', :phase => :aq, :name => 'Chloride ion', :cas => '16887-00-6', :weight => 35.4530 },
    { :formula => 'CH3COOH', :jess => 'H+1_Acetic-1_(l)', :name => 'Acetic acid', :phase => :l, :weight => 60.0526, 
                                :H_f => -483.5*KJ/MOL, :G_f => -396.46*KJ/MOL, :s => 158.0 },
    { :formula => 'CH3COOH', :jess => 'H+1_Acetic-1_(g)', :name => 'Acetic acid', :phase => :g, :weight => 60.0526,
                                :H_f => -433*KJ/MOL },
    { :formula => 'CH3COO-', :jess => 'Acetic-1', :phase => :aq, :G_f => -369.31 * KJ },
    { :formula => 'H2O', :jess => 'H2O', :phase => :l, 
                                :H_f => -285.83*KJ/MOL, :G_f => -237.13*KJ/MOL, :s => 69.95 },
    { :formula => 'H2O', :jess => 'H2O(g)', :phase => :g },
    { :formula => 'H+', :jess => 'H+1', :phase => :aq },
    { :formula => 'OH-', :jess => 'OH-1', :phase => :aq },
    { :formula => 'Na+', :phase => :aq },
    # http://webbook.nist.gov/cgi/cbook.cgi?ID=B6003067&Units=SI
    { :formula => 'CH3COONH4', :name => 'Ammonium acetate', :phase => :s, :weight => 77.0825 },
    { :formula => 'CH3COONH4', :name => 'Ammonium acetate', :phase => :aq },
    # http://webbook.nist.gov/cgi/inchi/InChI%3D1S/H3N/h1H3
    # http://en.wikipedia.org/wiki/Ammonia
    # http://en.wikipedia.org/wiki/Ammonia_%28data_page%29#Thermodynamic_properties
    # 1.5<H2(g)> + 0.5<N2(g)> = NH3(g)
    # 14 t=25 I=0 Inf. Dilution dG -16.45(4SF)kJ Wgt=5 ENS[7275]
    { :formula => 'NH3', :name => ['Ammonia','Ammoniakki'], :phase => :g, :jess => 'NH3(g)', :cas => '7664-41-7', :weight => 17.0305,
        :H_f => -45.94*KJ/MOL, :G_f => -16.45*KJ/MOL, :S => 192.77, 
        :H_melting => +5.653*KJ/MOL, :S_melting => +28.93, :T_melting => -77.75 + CELCIUS,
        :H_vaporisation => +23.33*KJ/MOL, :S_vaporisation => +97.41, :T_boil => -33.34 + CELCIUS },
    { :formula => 'NH3', :phase => :aq }, 
]
