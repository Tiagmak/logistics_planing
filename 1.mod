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

var venus_r, >= 0;
var venus_c, >= 0;
var venus_i, >= 0;
var mars_r, >= 0;
var mars_c, >= 0;
var mars_i, >= 0;
var mercury_r, >= 0;
var mercury_c, >= 0;
var mercury_i, >= 0;

s.t. venus: venus_r + venus_c + venus_i <= shuttle_capacity;
s.t. mars: mars_r + mars_c + mars_i <= shuttle_capacity;
s.t. mercury: mercury_r + mercury_c + mercury_i <= shuttle_capacity;

s.t. prod_r: venus_r + mars_r + mercury_r <= min(capacity_r["Cleaning"], capacity_r["Cooking"], capacity_r["Packing"]);
s.t. prod_c: venus_c + mars_c + mercury_c <= min(capacity_c["Cleaning"], capacity_c["Cooking"], capacity_c["Packing"]);
s.t. prod_i: venus_i + mars_i + mercury_i <= min(capacity_i["Cleaning"], capacity_i["Cooking"], capacity_i["Packing"]);

maximize profit{m in month}: venus_r * venus_price_r[m] + venus_c * venus_price_c[m] + venus_i * venus_price_i[m] +
                             mars_r * mars_price_r[m] + mars_c * mars_price_c[m] + mars_i * mars_price_i[m] +
                             mercury_r * mercury_price_r[m] + mercury_c * mercury_price_c[m] + mercury_i * mercury_price_i[m];

solve;

end;
