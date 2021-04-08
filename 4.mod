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
param production_capacity_r{operations};
param production_capacity_c{operations};
param production_capacity_i{operations};

table data IN "CSV" "operations.csv": operations <- [Process], production_capacity_r ~ R, production_capacity_c ~ C, production_capacity_i ~ I;

param shuttle_capacity := 1000;

var venus_r{month}, >= 0, integer;
var venus_c{month}, >= 0, integer;
var venus_i{month}, >= 0, integer;
var mars_r{month}, >= 0, integer;
var mars_c{month}, >= 0, integer;
var mars_i{month}, >= 0, integer;
var mercury_r{month}, >= 0, integer;
var mercury_c{month}, >= 0, integer;
var mercury_i{month}, >= 0, integer;

s.t. venus{m in month}:   0 <= (venus_r[m]   + venus_c[m]   + venus_i[m])   <= shuttle_capacity;
s.t. mars{m in month}:    0 <= (mars_r[m]    + mars_c[m]    + mars_i[m])    <= shuttle_capacity;
s.t. mercury{m in month}: 0 <= (mercury_r[m] + mercury_c[m] + mercury_i[m]) <= shuttle_capacity;

set storage_month := 1..13;
var storage_r{storage_month}, >= 0, integer;
var storage_c{storage_month}, >= 0, integer;
var storage_i{storage_month}, >= 0, integer;
s.t. _storage_r_start: storage_r[1] = 0;
s.t. _storage_c_start: storage_c[1] = 0;
s.t. _storage_i_start: storage_i[1] = 0;
s.t. _storage_r_end: storage_r[13] = 0;
s.t. _storage_c_end: storage_c[13] = 0;
s.t. _storage_i_end: storage_i[13] = 0;

var sent_r{month}, >= 0;
s.t. _sent_r{m in month}: sent_r[m] = venus_r[m] + mars_r[m] + mercury_r[m];
var sent_c{month}, >= 0;
s.t. _sent_c{m in month}: sent_c[m] = venus_c[m] + mars_c[m] + mercury_c[m];
var sent_i{month}, >= 0;
s.t. _sent_i{m in month}: sent_i[m] = venus_i[m] + mars_i[m] + mercury_i[m];

var prod_r{month}, >= 0, integer;
var prod_c{month}, >= 0, integer;
var prod_i{month}, >= 0, integer;
s.t. _store_r{m in month}: storage_r[m + 1] = prod_r[m] + storage_r[m] - sent_r[m];
s.t. _store_c{m in month}: storage_c[m + 1] = prod_c[m] + storage_c[m] - sent_c[m];
s.t. _store_i{m in month}: storage_i[m + 1] = prod_i[m] + storage_i[m] - sent_i[m];

s.t. production_capacity{m in month, op in operations}:
    0 <= ((prod_r[m] / production_capacity_r[op]) + (prod_c[m] / production_capacity_c[op]) + (prod_i[m] / production_capacity_i[op])) <= 1;

var storage_cost{storage_month} >= 0;
s.t. _storage_cost{m in storage_month}: storage_cost[m] = (storage_r[m] + storage_c[m] + storage_i[m]);

var profit_r{m in month};
s.t. _profit_r{m in month}: profit_r[m] = ((venus_r[m] * venus_price_r[m]) + (mars_r[m] * mars_price_r[m]) + (mercury_r[m] * mercury_price_r[m]));
var profit_c{m in month};
s.t. _profit_c{m in month}: profit_c[m] = ((venus_c[m] * venus_price_c[m]) + (mars_c[m] * mars_price_c[m]) + (mercury_c[m] * mercury_price_c[m]));
var profit_i{m in month};
s.t. _profit_i{m in month}: profit_i[m] = ((venus_i[m] * venus_price_i[m]) + (mars_i[m] * mars_price_i[m]) + (mercury_i[m] * mercury_price_i[m]));

var profit{month};
s.t. _profit{m in month}: profit[m] = (profit_r[m] + profit_c[m] + profit_i[m] - storage_cost[m]);

maximize annual_profit: sum{m in month} profit[m];

solve;

end;
