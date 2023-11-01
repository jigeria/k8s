create table CARD_INFO (user_id SERIAL PRIMARY KEY, user_name VARCHAR(50) UNIQUE NOT NULL, card_number VARCHAR(50) NOT NULL);
insert into CARD_INFO VALUES (1,'sangmin','1234-5678-5592-2323');
insert into CARD_INFO VALUES (2,'park','1234-5678-5592-2323');
insert into CARD_INFO VALUES (3,'jigeria','1234-5678-5592-2323');
commit;