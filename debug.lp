#include "gridControl.lp".
#include "robotMovement.lp".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sort and Object Declaration %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each Robot may but not necessarily have to do any action(move,pickup,dropoff) in a given time instance.
{robotmove(R,DX,DY,T): move(DX,DY)}1:-  robot(R), T=0..t-1.
{pickup(R,S,T): shelf(S)}1:- robot(R), T=0..t-1.
{dropoff(R,S,T):shelf(S)}1:- robot(R), T=0..t-1.
{delivery(R,O,S,I,UI,T):deliverAt(O,object(node,C),contains(I,U2),T), productOn(I,object(shelf,S),with(quant,U),T), UI=1..U}1:- robot(R), T=0..t-1.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Effects and Precondtions of Actions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
occurs(object(robot,R),move(DX,DY),T):- robotmove(R,DX,DY,T).
occurs(object(robot,R),pickup,T):- pickup(R,S,T).
occurs(object(robot,R),putdown,T):- dropoff(R,S,T).
occurs(object(robot,R),deliver(O,I,U),T):- delivery(R,O,S,I,U,T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% State Description %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Robot Constraints %%%%%
% A robot can only perform atmost one action per time instance.
:- occurs(object(robot,R),Ac1,T), occurs(object(robot,R),Ac2,T), Ac1!=Ac2, T=0..t-1.

% A robot cannot swap with other robots on it.
:- occurs(object(robot,R1),move(DX1,DY1),T), robotAt(R1,object(node,C1),T), occurs(object(robot,R2),move(DX2,DY2),T), robotAt(R2,object(node,C2),T), R1!=R2, C1!=C2, nodeAt(C1,pair(X1,Y1)), nodeAt(C2,pair(X2,Y2)), X1+DX1 = X2, X2+DX2 = X1, Y1+DY1=Y2, Y2+DY2=Y1.

% A robot cannot move outside the initialized grid in Warehouse.
:- robotmove(R,DX,DY,T), robotAt(R,object(node,C),T), nodeAt(C,pair(X,Y)), X+DX > L, numGridLength(L).
:- robotmove(R,DX,DY,T), robotAt(R,object(node,C),T), nodeAt(C,pair(X,Y)), X+DX < 1.
:- robotmove(R,DX,DY,T), robotAt(R,object(node,C),T), nodeAt(C,pair(X,Y)), Y+DY > W, numGridWidth(W).
:- robotmove(R,DX,DY,T), robotAt(R,object(node,C),T), nodeAt(C,pair(X,Y)), Y+DY < 1.

% A same robot cannot be on more than one cell/location.
:- robotAt(R,object(node,C1),T), robotAt(R,object(node,C2),T), C1!=C2.
% Atmost one robot on a given cell/location.
:- robotAt(R1,object(node,C1),T), robotAt(R2,object(node,C1),T), R1!=R2.
% A robot cannot go to a cell with shelf if it has a shelf on it before.
:- shelfAt(S,object(robot,R),T), robotAt(R,object(node,C),T), shelfAt(S1,object(node,C),T), S!=S1.

%%%%% Shelf Constraints %%%%%
% A shelf can be at only one cell/location. (only on one node/robot in a grid and can only be either on a node or on a robot)
% A Shelf cannot be at two cells at a given time instance T.
:- shelfAt(S,object(node,C),T), shelfAt(S,object(node,C1),T), C!=C1, T=0..t-1.
% A Shelf cannot be at two robots at a given time instance T.
:- shelfAt(S,object(robot,R),T), shelfAt(S,object(robot,R1),T), R!=R1, T=0..t-1.
% A Shelf cannot be at at a cell and on robot at a given time instance T.
:- shelfAt(S,object(node,C),T), shelfAt(S,object(robot,R),T), T=0..t-1.
% Two different shelves cannot be on the same robot at a given time instance T.
:- shelfAt(S1, object(robot,R),T), shelfAt(S2,object(robot,R),T), S1!=S2, T=0..t-1.
% Two or more shelves cannot be on one node.
:- not {shelfAt(S,object(node,C),T): shelf(S)}1, node(C), T=0..t-1.

%%%%% Pickup Constraints %%%%%
% A robot can only pickup one shelf which is on its current cell/location.
:- robotAt(R,object(node,C),T), shelfAt(S,object(node,C1),T), pickup(R,S,T), C!=C1, T=0..t-1.

% Only one robot can pickup the shelf.
:- pickup(R,S,T), pickup(R1,S,T), R!=R1.

% Only the shelf picked up by robot should be on it.
:- pickup(R,S,T), shelfAt(S,object(robot,R1),T), R!=R1, T=0..t-1.

% A robot cannot pick other shelf if already has one on it.
:- shelfAt(S,object(robot,R),T), occurs(object(robot,R),pickup,T), pickup(R,S1,T). %Check on this.
%:- pickup(R,S1,T), shelfAt(S,object(robot,R),T), S!=S1.

%%%%% Dropoff Constraints %%%%%
% A robot cannot dropoff shelf if it does not have it.
:- dropoff(R,S,T), not shelfAt(S,object(robot,R),T), T=0..t-1.
% A robot cannot put down shelf on highway
:- shelfAt(S,object(robot,R),T), dropoff(R,S,T), robotAt(R,object(node,C),T), highway(C).
%% A shelf cant be putDown by 2 robots
%:- 2{putdown(R,S,T): robot(R)}, shelf(S).

%%%%% Highway Constraints %%%%%
% Shelf cannot be on the Highway.
:- highway(C), shelfAt(S,object(node,C),T), T=0..t-1.
% picking station cannot be on the Highway.
% already added in the setupWarehouse.lp

%%%%% Delivery Constraints %%%%%
% A robot need to be on the order picking station.
:- delivery(R,O,S,I,U,T), robotAt(R,object(node,C),T), deliverAt(O,object(node,C1),contains(I,U),T), C!=C1.
% Delivery is only possible if robot has the product on its shelf that was ordered.
:- shelfAt(S,object(robot,R),T), productOn(I,object(shelf,S), with(quant,0),T), delivery(R,O,S,I,_,T).
% Delivery is only possible if robot has the shelf with the ordered product.
:- not shelfAt(S,object(robot,R),T), productOn(I,object(shelf,S),with(quant,_),T), delivery(R,O,S,I,_,T).
% Delivery of more than the asked units of products in an order is not possible.
:- delivery(R,O,S,I,U1,T), deliverAt(O,object(node,C),contains(I,U2),T), U1>U2.

% Delivery not allowed if the asked amount of units of a product is more than available units of the product on the shelf.
:- delivery(R,O,S,I,U1,T), productOn(I,object(shelf,S),with(quant,U2),T), U1>U2.
:- deliverAt(O,object(node,C),contains(I,U),T), U<0.
:- productOn(I,object(shelf,S),with(quant,U),T), U<0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Action Effect %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Moving a robot.
robotAt(R,object(node,C),T+1):- robotAt(R,object(node,C1),T), robotmove(R,DX,DY,T), nodeAt(C1, pair(X,Y)), nodeAt(C, pair(X+DX,Y+DY)).
% Robot picking a shelf.
shelfAt(S,object(robot,R),T+1):- robot(R), robotAt(R,object(node,C),T), shelfAt(S,object(node,C),T), pickup(R,S,T).
% Robot dropoff shelf.
shelfAt(S,object(node,C),T+1):- robotAt(R,object(node,C),T), shelfAt(S,object(robot,R),T), dropoff(R,S,T).
% Robot delivering the order, so the amount of item required get reduced by the amount delivered and some for product inventory in Warehouse.
deliverAt(O,object(node,C),contains(I,U-U1),T+1):- deliverAt(O,object(node,C),contains(I,U),T), delivery(R,O,S,I,U1,T).
productOn(I,object(shelf,S),with(quant,U-U1),T+1):- productOn(I,object(shelf,S),with(quant,U),T), delivery(R,O,S,I,U1,T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Law of Inertia %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A robot does not change location if no move action is done on it.
robotAt(R,object(node,C),T+1):- robotAt(R,object(node,C),T), not robotmove(R,_,_,T), T<t.
% A shelf remains at the same cell/location if no action(like pickup) is done on it.
shelfAt(S,object(node,C),T+1):- shelfAt(S,object(node,C),T), not pickup(_,S,T), T<t.
% A shelf remain on a robot if no dropoff action is done on it.
shelfAt(S,object(robot,R),T+1):- shelfAt(S,object(robot,R),T), not dropoff(R,S,T), T<t.
% An order is not complete if it is not yet delivered.
deliverAt(O,object(node,C),contains(I,U),T+1):- deliverAt(O,object(node,C),contains(I,U),T), productOn(I,object(shelf,S),with(quant,U1),T), not delivery(_,O,S,I,U1,T), T<t.
% Units of product on a shel remains the same if not delivered in any order.
productOn(I,object(shelf,S),with(quant,U),T+1):- productOn(I,object(shelf,S),with(quant,U),T), not delivery(_,_,S,I,_,T), T<t.

% Goal state
:- not deliverAt(O,object(node,C),contains(I,0),t), deliverAt(O,object(node,C),contains(I,U),0).

#show occurs/3.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the minimum %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Total number of actions in a plan.
totalActions(N):- N=#count{Obj,Ac,T:occurs(Obj,Ac,T)}.
% We want to minimize the Makespan(Time t for completing the action plan).
overallTime(TT):- TT=#count{T:occurs(Obj,Ac,T)}.
#minimize{TT:overallTime(TT)}.
%#minimize{N:totalActions(N)}.
#show totalActions/1.
#show overallTime/1.
