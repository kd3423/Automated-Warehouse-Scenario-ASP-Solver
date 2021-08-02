#include "setupWarehouse.lp".

% Length and width of the Warehouse grid.
numGridWidth(N):- N=#count{X:nodeAt(C,pair(X,Y))}.
numGridLength(N):- N=#count{Y:nodeAt(C,pair(X,Y))}.
% Total number of cells/nodes initialized during the init state.
numTotalCells(N):- N=#count{C:node(C)}.

% Number of robots in the Warehouse.
numRobot(N):- N=#count{R:robot(R)}.

% Number of Shelves in the Warehouse.
numShelves(N):- N=#count{S:shelf(S)}.

% number of Orders
numOrders(N):- N=#count{O:order(O)}.

% Number of Picking Stations in Warehouse.
numPickingStation(N):- N=#count{P:pickingStation(P)}.

% Number of Highway cells declared in a Warehouse.
numHighway(N):- N=#count{C:highway(C)}.

% Number of products initially declared in a Warehouse.
numProducts(N):- N=#count{I:product(I)}.

%Check Grid for holes, if found the initial states are not valid
:- numTotalCells(N), numGridWidth(W), numGridLength(L), not N = W*L.


%#show numGridWidth/1.
%#show numGridLength/1.
%#show numTotalCells/1.
%#show numRobot/1.
%#show numShelves/1.
%#show numOrders/1.
%#show numPickingStation/1.
%#show numHighway/1.
%#show numProducts/1.
