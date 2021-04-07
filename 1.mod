set month;
param venus_price_r{month};
param venus_price_c{month};
param venus_price_i{month};
param mars_price_r{month};
param mars_price_c{month};
param mars_price_i{month};
param mercury_price_r{month};
param mercury_price_c{month};
param mercury_price_i{month};

table data IN "CSV" "demand.csv": month <- [Month],
                                  venus_price_r ~ VenusR, venus_price_c ~ VenusC, venus_price_i ~ VenusI,
                                  mars_price_r ~ MarsR, mars_price_c ~ MarsC, mars_price_i ~ MarsI,
                                  mercury_price_r ~ MercuryR, mercury_price_c ~ MercuryC, mercury_price_i ~ MercuryI;

set operations;
param capacity_r{operations};
param capacity_c{operations};
param capacity_i{operations};

table data IN "CSV" "operations.csv": operations <- [Process], capacity_r ~ R, capacity_c ~ C, capacity_i ~ I;

param shuttle_capacity := 1000;

var venus_r{month}, >= 0;
var venus_c{month}, >= 0;
var venus_i{month}, >= 0;
var mars_r{month}, >= 0;
var mars_c{month}, >= 0;
var mars_i{month}, >= 0;
var mercury_r{month}, >= 0;
var mercury_c{month}, >= 0;
var mercury_i{month}, >= 0;

s.t. venus{m in month}:   0 <= (venus_r[m]   + venus_c[m]   + venus_i[m])   <= shuttle_capacity;
s.t. mars{m in month}:    0 <= (mars_r[m]    + mars_c[m]    + mars_i[m])    <= shuttle_capacity;
s.t. mercury{m in month}: 0 <= (mercury_r[m] + mercury_c[m] + mercury_i[m]) <= shuttle_capacity;

var prod_r{m in month}, >= 0;
s.t. _prod_r{m in month}: prod_r[m] = (venus_r[m] + mars_r[m] + mercury_r[m]);
var prod_c{m in month}, >= 0;
s.t. _prod_c{m in month}: prod_c[m] = (venus_c[m] + mars_c[m] + mercury_c[m]);
var prod_i{m in month}, >= 0;
s.t. _prod_i{m in month}: prod_i[m] = (venus_i[m] + mars_i[m] + mercury_i[m]);

s.t. production_capacity{m in month, op in operations}: 0 <= ((prod_r[m] / capacity_r[op]) + (prod_c[m] / capacity_c[op]) + (prod_i[m] / capacity_i[op])) <= 1;

var profit_r{m in month};
s.t. _profit_r{m in month}: profit_r[m] = ((venus_r[m] * venus_price_r[m]) + (mars_r[m] * mars_price_r[m]) + (mercury_r[m] * mercury_price_r[m]));
var profit_c{m in month};
s.t. _profit_c{m in month}: profit_c[m] = ((venus_c[m] * venus_price_c[m]) + (mars_c[m] * mars_price_c[m]) + (mercury_c[m] * mercury_price_c[m]));
var profit_i{m in month};
s.t. _profit_i{m in month}: profit_i[m] = ((venus_i[m] * venus_price_i[m]) + (mars_i[m] * mars_price_i[m]) + (mercury_i[m] * mercury_price_i[m]));

maximize annual_profit: sum{m in month} (profit_r[m] + profit_c[m] + profit_i[m]);

var profit{month};
s.t. _profit{m in month}: profit[m] = (profit_r[m] + profit_c[m] + profit_i[m]);

solve;


end;
