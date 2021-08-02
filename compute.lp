#include "gridControl.lp".
#include "robotMovement.lp".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sort and Object Declaration %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each Robot may but not necessarily have to make an action in a given time instance.
{robotmove(R,DX,DY,T): move(DX,DY)}1:-  robot(R), T=0..t-1.
{pickup(R,S,T): shelf(S)}1:- robot(R), T=0..t-1.
{dropoff(R,S,T):shelf(S)}1:- robot(R), T=0..t-1.
{delivery(R,O,S,I,U,T):deliverAt(O,object(node,C),contains(I,U2),T), productOn(I,object(shelf,S),with(quant,U),T), UI=1..U}1:- robot(R), T=0..t-1.


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
% A robot cannot move to cell/location which has other robots on it.
:- occurs(object(robot,R1),move(DX1,DY1),T), robotAt(R1,object(node,C1),T), occurs(object(robot,R2),move(DX2,DY2),T), robotAt(R2,object(node,C2),T), R1!=R2, C1!=C2, nodeAt(C1,pair(X1,Y1)), nodeAt(C2,pair(X2,Y2)), X1+DX1 = X2, X2+DX2 = X1, Y1+DY1=Y2, Y2+DY2=Y1.


% a robot cannot move outside the initialized grid in Warehouse.
:- robotmove(R,DX,DY,T), robotAt(R,object(node,C),T), nodeAt(C,pair(X,Y)), X+DX > L, numGridLength(L).
:- robotmove(R,DX,DY,T), robotAt(R,object(node,C),T), nodeAt(C,pair(X,Y)), X+DX < 1.
:- robotmove(R,DX,DY,T), robotAt(R,object(node,C),T), nodeAt(C,pair(X,Y)), Y+DY > W, numGridWidth(W).
:- robotmove(R,DX,DY,T), robotAt(R,object(node,C),T), nodeAt(C,pair(X,Y)), Y+DY < 1.

% A same robot cannot be on more than one cell/location.
:- robotAt(R1,object(node,C1),T), robotAt(R1,object(node,C2),T), C1!=C2, T=0..t-1.
% Atmost one robot on a given cell/loccation.
:- robotAt(R1,object(node,C1),T), robotAt(R2,object(node,C1),T), R1!=R2, T=0..t-1.


% A shelf can be at only one cell/location. (only on one node in a grid and can only be either on a node or on a robot)
:- not {shelfAt(S,object(node,C),T):node(C)}1, shelf(S), T=0..t-1.
:- shelfAt(S,object(node,C),T), shelfAt(S,object(robot,R),T), T=0..t-1.

%% --
:- not {shelfAt(S,object(node,C),T):shelf(S)}1, node(C), T=0..t-1.


% A robot can only perform atmost one action per time instance.
:- occurs(object(robot,R),Ac1,T), occurs(object(robot,R),Ac2,T), Ac1!=Ac2.


:- shelfAt(S,object(node,C),T), robot(R), robotAt(R,object(node,C1),T), C!=C1, pickup(R,S,T).

% A robot cannot go on cell/location of other shelves when its carrying a shelf.
:- shelfAt(S,object(robot,R),T), robotAt(R,object(node,C),T), shelfAt(S1,object(node,C),T), S!=S1.

% A robot cannot put down shelf on highway
:- shelfAt(S,object(robot,R),T), dropoff(R,S,T), robotAt(R,object(node,C),T), highway(C).

% A robot can only put down shelf if it as one.
:- robot(R), not shelfAt(S,object(robot,R),T), dropoff(R,S,T).

%% More than 1 robot cannot pickup the same shelf S.
:- pickup(R,S,T), pickup(R1,S,T), R!=R1.
%:- not {pickup(R,S,T):robot(R)}1, shelf(S).

% one shelf cannot be on more than one robot at a given time. (Shelf can be on one robot or not)
:- not {shelfAt(S,object(robot,R),T): robot(R)}1, shelf(S), T=0..t.
%% atmost one shelf per robot at a given time. (Robot can have one shelf or not)
:- not {shelfAt(S,object(robot,R),T): shelf(S)}1, robot(R), T=0..t.




% Delivery is only possible if robot is at the cell/location of picking station.
:- robotAt(R,object(node,C1),T), deliverAt(O,object(node,C),contains(_,_),T), delivery(R,O,_,_,_,T), C!=C1.
%% Delivery is only possible if robot has a shelf on it.
:- not shelfAt(S,object(robot,R),T), deliverAt(O,object(node,C),contains(I,U),T), delivery(R,O,S,I,U,T), robotAt(R,object(node,C),T).
% Delivery is only possible if robot has the product on its shelf that was ordered.
:- shelfAt(S,object(robot,R),T), productAvail(I,0), delivery(R,O,S,I,_,T).

% Delivery of more than the asked units of products in an order is not possible.
%:- delivery(R,O,S,I,U1,T), deliverAt(O,object(node,C),contains(I,U2),T), U1>U2.

% Delivery not allowed if the asked amount of units of a product is more than available units of the product in the Warehouse.
%:- delivery(R,O,S,I,U1,T), productOn(I,object(shelf,S),with(quant,U2),T), U1>U2.
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
productAvail(I,U-U1):- delivery(R,_,_,I,U1,T).
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the minimum %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Total number of actions in a plan.
totalActions(N):- N=#count{Obj,Ac,T:occurs(Obj,Ac,T)}.
% We want to minimize the Makespan(Time t for completing the action plan).
overallTime(TT):- TT=#count{T:occurs(Obj,Ac,T),T>0}.
%#minimize{TT:overallTime(TT)}.

#show totalActions/1.
#show occurs/3.
#show overallTime/1.
