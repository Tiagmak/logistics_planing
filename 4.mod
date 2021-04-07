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

var storage_r{month, operations}, >= 0;
var storage_c{month, operations}, >= 0;
var storage_i{month, operations}, >= 0;
s.t. _storage_r{op in operations}: storage_r[1, op] = 0;
s.t. _storage_c{op in operations}: storage_c[1, op] = 0;
s.t. _storage_i{op in operations}: storage_i[1, op] = 0;

var prod_r{m in month, op in operations}, >= 0;
var prod_c{m in month, op in operations}, >= 0;
var prod_i{m in month, op in operations}, >= 0;
s.t. _clean_before_cooking_r{m in month}: prod_r[m, "Cooking"] <= (prod_r[m, "Cleaning"] + storage_r[m, "Cleaning"]);
s.t. _clean_before_cooking_c{m in month}: prod_c[m, "Cooking"] <= (prod_c[m, "Cleaning"] + storage_c[m, "Cleaning"]);
s.t. _clean_before_cooking_i{m in month}: prod_i[m, "Cooking"] <= (prod_i[m, "Cleaning"] + storage_i[m, "Cleaning"]);
s.t. _cook_before_packing_r{m in month}:  prod_r[m, "Packing"] <= (prod_r[m, "Cooking"]  + storage_r[m, "Cooking"]);
s.t. _cook_before_packing_c{m in month}:  prod_c[m, "Packing"] <= (prod_c[m, "Cooking"]  + storage_c[m, "Cooking"]);
s.t. _cook_before_packing_i{m in month}:  prod_i[m, "Packing"] <= (prod_i[m, "Cooking"]  + storage_i[m, "Cooking"]);
s.t. _available_r{m in month, op in operations}: venus_r[m] + mars_r[m] + mercury_r[m] <= (storage_r[m, op] + prod_r[m, op]);
s.t. _available_c{m in month, op in operations}: venus_c[m] + mars_c[m] + mercury_c[m] <= (storage_c[m, op] + prod_c[m, op]);
s.t. _available_i{m in month, op in operations}: venus_i[m] + mars_i[m] + mercury_i[m] <= (storage_i[m, op] + prod_i[m, op]);

s.t. production_capacity{m in month, op in operations}:
    0 <= ((prod_r[m, op] / production_capacity_r[op]) + (prod_c[m, op] / production_capacity_c[op]) + (prod_i[m, op] / production_capacity_i[op])) <= 1;

var storage_cost{month} >= 0;
s.t. _storage_cost{m in month}: storage_cost[m] = sum{op in operations} (storage_r[m, op] + storage_c[m, op] + storage_i[m, op]);

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
