
void dropDB() {
  pgsql = new PostgreSQL( this, host, database, user, pass );
  if ( pgsql.connect() )
  {
    pgsql.query( "SELECT max(id) FROM product;" );
    pgsql.next();
    int maxId = pgsql.getInt(1);

    for (int a = 1; a <= maxId; a++) {
      // query the number of entries in table "weather"
      pgsql.query( "drop view prod_id_" + a );
      wait(waitDB);
      println( "drop view prod_id_" + a );
    }
    pgsql.query( "drop trigger minuscula_product_name_on_insert_trigger on product" );
    println( "drop trigger minuscula_product_name_on_insert_trigger on product" );
    pgsql.query( "drop function minuscula_product_name_on_insert()" );
    println( "drop function minuscula_product_name_on_insert()" );
    pgsql.query( "drop table \"market\" cascade" );
    println( "drop table \"market\" cascade" );
    pgsql.query( "drop table \"register\" cascade" );
    println( "drop table \"register\" cascade" );
    pgsql.query( "drop table \"category\" cascade" );
    println( "drop table \"category\" cascade" );
    pgsql.query( "drop table \"product\" cascade" );
    println( "drop table \"product\" cascade" );
    pgsql.query( "drop table \"search\" cascade" );
    println( "drop table \"product\" cascade" );


    pgsql.query( "CREATE TABLE \"market\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )");
    println( "CREATE TABLE \"market\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )" );
    pgsql.query( "CREATE TABLE \"product\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )");
    println( "CREATE TABLE \"product\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )" );
    pgsql.query( "CREATE TABLE \"category\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )");
    println( "CREATE TABLE \"category\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )" );
    pgsql.query( "CREATE TABLE \"register\" (\"id\" bigserial NOT NULL PRIMARY KEY,\"id_product\" integer NOT NULL REFERENCES product(\"id\"),\"id_category\" integer NOT NULL REFERENCES category(\"id\"),\"id_market\" integer NOT NULL REFERENCES market(\"id\"),\"price\" float,\"deprice\" float,\"datedate\" date,\"created_at\" timestamp,\"imagelink\" varchar(200) )");
    println( "CREATE TABLE \"register\" (\"id\" bigserial NOT NULL PRIMARY KEY,\"id_product\" integer NOT NULL REFERENCES product(\"id\"),\"id_category\" integer NOT NULL REFERENCES category(\"id\"),\"id_market\" integer NOT NULL REFERENCES market(\"id\"),\"price\" float,\"deprice\" float\"datedate\" date,\"created_at\" timestamp,\"imagelink\" varchar(200) )" );
    pgsql.query( "CREATE TABLE \"search\" (\"id\" bigserial NOT NULL PRIMARY KEY,\"word\" varchar(200),\"qty_results\" integer,\"created_at\" timestamp )");
    println( "CREATE TABLE \"search\" (\"id\" bigserial NOT NULL PRIMARY KEY,\"word\" varchar(200),\"qty_results\" integer,\"created_at\" timestamp )" );
    pgsql.query( "INSERT INTO market(name, created_at) VALUES(\'zona sul\', current_timestamp)");
    println( "INSERT INTO market(name, created_at) VALUES(\'zona sul\', current_timestamp)" );
    pgsql.query( "INSERT INTO market(name, created_at) VALUES(\'pao de acucar\', current_timestamp)");
    println( "INSERT INTO market(name, created_at) VALUES(\'pao de acucar\', current_timestamp)" );
    pgsql.query( "INSERT INTO market(name, created_at) VALUES(\'extra\', current_timestamp)");
    println( "INSERT INTO market(name, created_at) VALUES(\'extra\', current_timestamp)");
    pgsql.query( "CREATE OR REPLACE FUNCTION minuscula_product_name_on_insert() RETURNS trigger AS $minuscula_product_name_on_insert$ BEGIN NEW.name = LOWER(NEW.name); RETURN NEW; END; $minuscula_product_name_on_insert$ LANGUAGE plpgsql; ");
    println( "CREATE OR REPLACE FUNCTION minuscula_product_name_on_insert() RETURNS trigger AS $minuscula_product_name_on_insert$ BEGIN NEW.name = LOWER(NEW.name); RETURN NEW; END; $minuscula_product_name_on_insert$ LANGUAGE plpgsql; " );
    pgsql.query( "CREATE TRIGGER minuscula_product_name_on_insert_trigger BEFORE INSERT OR UPDATE ON product FOR EACH ROW EXECUTE PROCEDURE minuscula_product_name_on_insert();");
    println( "CREATE TRIGGER minuscula_product_name_on_insert_trigger BEFORE INSERT OR UPDATE ON product FOR EACH ROW EXECUTE PROCEDURE minuscula_product_name_on_insert();");
  }
  pgsql = null;
}
/*
 
 drop table "market", "register", "category", "product" CASCADE;
 drop trigger minuscula_product_name_on_insert_trigger on product;
 drop function minuscula_product_name_on_insert();
 
 CREATE TABLE "market"
 (
 "id" serial NOT NULL PRIMARY KEY,
 "name" varchar(200),
 "created_at" timestamp
 );
 
 CREATE TABLE "product"
 (
 "id" serial NOT NULL PRIMARY KEY,
 "name" varchar(200),
 "created_at" timestamp
 );
 
 CREATE TABLE "category"
 (
 "id" serial NOT NULL PRIMARY KEY,
 "name" varchar(200),
 "created_at" timestamp
 );
 
 CREATE TABLE "register"
 (
 "id" bigserial NOT NULL PRIMARY KEY,
 "id_product" integer NOT NULL REFERENCES product("id"),
 "id_category" integer NOT NULL REFERENCES category("id"),
 "id_market" integer NOT NULL REFERENCES market("id"),
 "price" float,
 "datedate" date,
 "created_at" timestamp,
 "imagelink" varchar(200)
 );
 
 CREATE TABLE "search" 
 (
 "id" bigserial NOT NULL PRIMARY KEY,
 "word" varchar(200),
 "qty_results" integer,
 "created_at" timestamp
 );
 
 INSERT INTO market(name, created_at) 
 VALUES('zona sul', current_timestamp);
 INSERT INTO market(name, created_at) 
 VALUES('pao de acucar', current_timestamp);
 INSERT INTO market(name, created_at) 
 VALUES('extra', current_timestamp);
 

 CREATE OR REPLACE FUNCTION minuscula_product_name_on_insert() RETURNS trigger AS $minuscula_product_name_on_insert$
 BEGIN        
 NEW.name = LOWER(NEW.name);
 RETURN NEW;
 END;
 $minuscula_product_name_on_insert$ LANGUAGE plpgsql;
 
 CREATE TRIGGER minuscula_product_name_on_insert_trigger BEFORE INSERT OR UPDATE ON product
 FOR EACH ROW EXECUTE PROCEDURE minuscula_product_name_on_insert();
 
 INSERT INTO product (name, created_at) VALUES ('LOWERCASE ME', current_timestamp);
 
 SELECT max(id) FROM product;
 
 
 
 
 
 INSERT INTO product(id_market,name, created_at) 
 SELECT 1,'manteiga',current_timestamp
 WHERE NOT EXISTS(
 SELECT name FROM product where name = 'manteiga')
 RETURNING id;
 
 INSERT INTO category(name, created_at) 
 SELECT 'cervejas',current_timestamp
 WHERE NOT EXISTS(
 SELECT name FROM category where name = 'cervejas');
 
 INSERT INTO register(id_product,id_category,price,datedate,created_at,imagelink)
 VALUES(
 (SELECT id FROM product WHERE name = 'manteiga'),
 (SELECT id FROM category WHERE name = 'cervejas'),
 3.2,current_date,current_timestamp,'http://www...');
 
 
 SELECT * 
 FROM register 
 WHERE datedate 
 BETWEEN '2015-09-09' 
 AND '2015-09-09';
 
 
 SELECT * 
 FROM register 
 WHERE id_product 
 IN (SELECT id 
 FROM product 
 WHERE id_market = 2);
 
 */
