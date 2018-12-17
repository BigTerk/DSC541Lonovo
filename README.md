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


### Deliverables:

A simulation was derived from the theoretical findings, which can be viewed on the theoretical documentation "Lenovo Paper.docx". Once
run, the simulationwill produce a csv file of the finished good serviceabilities, item part level serviceabilities, and a part level 
serviceability by finished good for each batch, at a given noise level. The noise level, the number of simulations, as well as how many 
batches of each simulation are global variables and can be changed freely to suit any request needed.

Once each of the simulations were run, the mean serviceability for each batch were calculated to produce the overall serviceability for 
each of the noise levels provided.

### To Run the Simulation:
  1) Download repository from this GitHub
  2) Run the "Simulation_Full.ipynb" file on a Jupyter Notebook (Other notebooks are for testing and creating this final simulation)
        - 2a) To run properly, the notebook must be run on a local network
        - 2b) The "finished_good_parts.csv" must be imported from the GitHub as well
  3) The resulting csv files of the simulation will be produced and stored in the "Sericeability_Output" folder
        - 3a) The "Sericeability_Output" will result in a zip file. This must be unziped to view the serviceability csvs
  4) The overall mean serviceabilities can be determined by running the "mean_csv(2).ipynb" Jupyter Notebook
        - 4a) Important note: the "mean_csv(2).ipynb" notebook will only work if the csvs from the "Sericeability_Output"  and the 
            "mean_csv(2).ipynb" notebook are contained in the same folder
