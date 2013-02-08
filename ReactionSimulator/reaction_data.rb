require 'physical_constants'

# new comment
# http://en.wikipedia.org/wiki/Chemical_equilibrium
# L1 + L2  <--->   R1 + R2
# [R1][R2]/[L1][L2] = K
# dG = -RT ln(K)   (ln = Natural logarithm, energy = Joules)
# dG = -2.303*RT log-10(K)   (log-10 = log = lg = 10-based logarithm)
# log-10(K) = -dG / -2.303*RT = -dG(J) / 5706.2 = -0.175 * dG(kJ)
# dG = dH - T*dS   
# Eg. for water formation from JESS: lgK = 41.55, dG -56.69 kCal/mol = -237.2 kJ/mol
# We can calculate: dG = -2.303*8.314472*298 * 41.55 = -237.1 kJ/mol    
        
# NOTE: We don't use *activities* here, activities are *dimensionless*:
# http://en.wikipedia.org/wiki/Activity_%28chemistry%29
# "The division by the standard molality mo or the standard amount concentration 
# co is necessary to ensure that both the activity and the activity coefficient 
# are dimensionless, as is conventional." M0 and C0 = 1 mol/l

# NOTE: Be careful not to include set of redundant reactions (will cause convergence problems). Eg:
# [H+][OH-] = 1.0e-14
# [H+][NH3]/[NH4+] = 5.75e-10
# from these we can derive by substitution from first [H+] = 1.0e-14/[OH-]
# -> [NH3]/([OH-][NH4+]) = 5.75e-10 / 1.0e-14 = 5.75e4
# -> [OH-][NH4+]/[NH3] = 1/5.75e4 = 1.73913043478261e-005
# So we should not include [OH-][NH4+]/[NH3] = 1.8e-5 in our balance equations if we already have first two.
# In Theory it should not matter if we have reduntant reactions (the redundant one should converge if others converge) 
# but in practice we should have to have their equilibrium constants match each other extremely accurately, 
# eg. use 1.73913043478261e-005 instead of 1.8e-5
# to make it match two others, otherwise there is a contradiction in our set of equations and they will not converge.
    
# Note: :K is slightly affected by other diluted species... Probably we can't account for that.
# Note: :lgK in formulas (eg. JESS) is 10-based logarithm
# Note: For water dissociation, the [H+][OH-] = Kw = 10e-14, So H2O concentration is *not* taken into account in the formula.
#       We have incorporated it there with 55.55 M H2O, so lgK 14 -> 15.74


# TODO: Make possible to give reaction data as dG(r) in explicitly given units (eg. kcal/mol)
# and K will be calculated from this by our program!
REACTION_DATA =
[   # H2(g) + 0.5<O2(g)> = H2O   (water formation)
    # 1 t=25 I=0 Inf. Dilution  lgK 41.55(4SF) Wgt=4 ENS[6422]
    # 5 t=25 I=0 Inf. Dilution  dG -56.69(0.005SD) Wgt=3 CRV[5169]
    { :left => [ [1,'H2(g)'], [0.5,'O2(g)'] ], :right => [ [1, 'H2O(l)'] ], :celsius => 25.0, :K => 3.55e+41 },
    { :left => [ [1,'H2O(l)'] ], :right => [ [1,'H+(aq)'], [1,'OH-(aq)'] ], :celsius => 25.0, :K => 1.0e-14 / C_WATER },
    { :left => [ [1,'CH3COOH(l)'] ], :right => [ [1,'CH3COO-(aq)'], [1,'H+(aq)'] ], :celsius => 25.0, :K => 1.78e-5 },
    # JESS: H+1 + NH3 = H+1_NH3: 26 t=25 I=0 Inf. Dilution, lgK 9.24(3SF) Wgt=4 CRV[8749]
    { :left => [ [1,'NH4+(aq)'] ], :right => [ [1,'H+(aq)'], [1,'NH3(aq)'] ], :celsius => 25.0, :K => 5.75e-10 }, # 10 ** -9.24 = 5.75e-10
    # http://en.wikipedia.org/wiki/Ammonium_hydroxide
    # REDUNDANT REACTION based on earlier ones, DON'T INCLUDE
    # { :left => [ [1,'NH3(aq)'], [1,'H2O(l)'] ], :right => [ [1,'NH4+(aq)'], [1,'OH-(aq)'] ], :celsius => 25.0, :K => 1.8e-005 / C_WATER },
]        
