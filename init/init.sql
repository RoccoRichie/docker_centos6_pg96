CREATE SCHEMA records;
SET search_path TO records;

CREATE TABLE customers (
    customer_id UUID NOT NULL,
    firstname varchar(50) NOT NULL,
    lastname varchar(100) NOT NULL,
    age integer NOT NULL,
    PRIMARY KEY(customer_id)
);

INSERT INTO customers (customer_id, firstname, lastname, age) VALUES ('0999d22c-416a-11e8-842f-0ed5f89f718b',
'peter', 'pan', 19);
INSERT INTO customers (customer_id, firstname, lastname, age) VALUES ('0999d998-416a-11e8-842f-0ed5f89f718b',
'rogerio', 'smith', 19);
INSERT INTO customers (customer_id, firstname, lastname, age) VALUES ('0999dc7c-416a-11e8-842f-0ed5f89f718b',
'mike', 'brown', 19);