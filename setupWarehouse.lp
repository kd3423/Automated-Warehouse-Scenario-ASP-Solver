pair(X,Y):- init(object(node,C),value(at,pair(X,Y))).
nodeAt(C,pair(X,Y)):- init(object(node,C),value(at,pair(X,Y))).
node(C):- nodeAt(C,pair(X,Y)).

highwayAt(C,pair(X,Y)):- init(object(highway,C),value(at,pair(X,Y))).
highway(C):- highwayAt(C,pair(X,Y)).

robotAt(R,object(node,C),0):- init(object(robot,R),value(at,pair(X,Y))), nodeAt(C,pair(X,Y)).
robot(R):- robotAt(R,object(node,C),0).

shelfAt(S,object(node,C),0):- init(object(shelf,S),value(at,pair(X,Y))), nodeAt(C,pair(X,Y)), not highwayAt(C,pair(X,Y)).
shelf(S):- shelfAt(S,object(node,C),0).

productOn(I,object(shelf,S),with(quant,U),0):- init(object(product,I),value(on,pair(S,U))).
product(I):- productOn(I,object(shelf,S),with(quant,U),0).

pickingStationAt(P,C):- init(object(pickingStation,P),value(at,pair(X,Y))), not highwayAt(C,pair(X,Y)), nodeAt(C,pair(X,Y)).
pickingStation(P):- pickingStationAt(P,C).

order(O):- init(object(order,O),value(pickingStation,P)).
deliverAt(O,object(node,C),contains(I,U),0):- init(object(order,O),value(line,pair(I,U))), pickingStationAt(P,C), init(object(order,O),value(pickingStation,P)).
