SET SERVEROUTPUT ON;

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE inventory';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE products';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(50)
);

CREATE TABLE inventory (
    product_id NUMBER,
    quantity NUMBER,
    CONSTRAINT inv_fk FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SET TRANSACTION NAME 'inventory_update';

INSERT INTO products (product_id, product_name) VALUES (1, 'Laptop');

INSERT INTO inventory (product_id, quantity) VALUES (1, 10);

SAVEPOINT after_add_inventory;

UPDATE inventory SET quantity = quantity - 15 WHERE product_id = 1;

DECLARE
    v_quantity NUMBER;
BEGIN
    SELECT quantity INTO v_quantity FROM inventory WHERE product_id = 1;
    IF v_quantity < 0 THEN
        ROLLBACK TO SAVEPOINT after_add_inventory;
        DBMS_OUTPUT.PUT_LINE('Rollback performed: Inventory cannot go negative.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Transaction committed.');
    END IF;
END;
/

SELECT * FROM inventory;
