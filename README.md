# DSC541Lonovo
Create a production model for a multicomponent, multiproduct production and inventory system.   

Objective: Implement the serviceability interconversion between finished goods and components.
Description: One finished good is made by multi-components. One component can be used in different finished goods.
BOM (billing of materials) will be provided to connect finished goods and components. The analysis should implement the 
following two functions:

1. When a serviceability is set in finished goods level, the serviceability of each component will be calculated while minimizing the 
serviceability of each component.

2. If predefine serviceability of all components, then a serviceability in finished good will be 
calculated while maximizing the serviceability of finish goods.


Definition of serviceability: the probability of not stock-out when an order is placed. One month serviceability is calculated by the
number of orders that delayed by stock-out/the total number of orders in this month. The quantity of products in one order 
does not impact serviceability.

### Meeting Updates - 10/31/18
- Randomize 5 new FG
- Find proportion of shared parts between current available FG
- Need to generate random orders (# distinct FG, Qty of each FG, Poisson Distribution)
- Consider median around 20
- Reference:  numpy.random.poisson(lam=1.0, size=None)
- Determine stock levels for each part in inventory
