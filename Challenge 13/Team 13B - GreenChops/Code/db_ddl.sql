--drop table "public".Office_Elec_and_Gas_co2;
--drop table "public".asset_configuration;
--drop table "public".Office_Elec_and_Gas_kwh;
--drop table "public".Office_Weather;
--drop table "public".office_configuration
--drop table "public".occupancy_options
--drop view vw_optimum_co2;

CREATE TABLE "public".Office_Elec_and_Gas_co2
(
 year      varchar(4) NOT NULL,
 month     varchar(5) NOT NULL,
 office_id varchar(50) NOT NULL,
 co2_ppm   bigint NOT NULL,
 CONSTRAINT PK_2 PRIMARY KEY ( year, month, office_id )--,
 --CONSTRAINT FK_5 FOREIGN KEY ( year, month, office_id ) REFERENCES "public".Office_Elec_and_Gas_kwh ( year, month, office_id )
);

CREATE INDEX FK_1 ON "public".Office_Elec_and_Gas_co2
(
 year,
 month,
 office_id
);

CREATE TABLE "public".asset_configuration
(
 asset_id           bigint NOT NULL,
 office_id          varchar(50) NOT NULL,
 asset_type         varchar(50) NOT NULL,
 asset_name         varchar(50) NOT NULL,
 asset_energy_usage bigint NOT NULL,
 CONSTRAINT PK_1 PRIMARY KEY ( asset_id )--,
 --CONSTRAINT FK_1 FOREIGN KEY ( office_id ) REFERENCES "public".office_configuration ( office_id )
);

CREATE INDEX FK_2 ON "public".asset_configuration
(
 office_id
);

/*
CREATE TABLE "public".Office_Elec_and_Gas_kwh
(
 year                varchar(4) NOT NULL,
 month               varchar(5) NOT NULL,
 office_id           varchar(50) NOT NULL,
 "Electricity (kWh)" bigint NULL,
 "Gas (kWh)"         bigint NULL,
 CONSTRAINT PK_1 PRIMARY KEY ( year, month, office_id ),
 CONSTRAINT FK_4 FOREIGN KEY ( office_id ) REFERENCES "public".office_configuration ( office_id )
);

CREATE INDEX FK_2 ON "public".Office_Elec_and_Gas_kwh
(
 office_id
);
*/

CREATE TABLE "public".Office_Weather
(
 year         varchar(4) NOT NULL,
 month        varchar(5) NOT NULL,
 office_id    varchar(50) NOT NULL,
 temp_c       int NOT NULL,
 weather_desc varchar(30) NOT NULL,
 CONSTRAINT PK_2n PRIMARY KEY ( year, month, office_id )--,
 --CONSTRAINT FK_6 FOREIGN KEY ( year, month, office_id ) REFERENCES "public".Office_Elec_and_Gas_kwh ( year, month, office_id )
);

CREATE INDEX FK_1 ON "public".Office_Weather
(
 year,
 month,
 office_id
);


CREATE TABLE "public".occupancy_options
(
 year             varchar(4) NOT NULL,
 month            varchar(5) NOT NULL,
 office_id        varchar(50) NOT NULL,
 which_floor      int NOT NULL,
 people_per_floor bigint NULL,
 CONSTRAINT PK_3 PRIMARY KEY ( year, month, office_id, which_floor )--,
 --CONSTRAINT FK_2 FOREIGN KEY ( office_id ) REFERENCES "public".office_configuration ( office_id ),
 --CONSTRAINT FK_3 FOREIGN KEY ( year, month, office_id ) REFERENCES "public".Office_Elec_and_Gas_kwh ( year, month, office_id )
);

CREATE INDEX FK_2 ON "public".occupancy_options
(
 office_id
);

CREATE INDEX FK_3 ON "public".occupancy_options
(
 year,
 month,
 office_id
);

CREATE TABLE "public".office_configuration
(
 office_id        varchar(50) NOT NULL,
 no_of_floors     int NOT NULL,
 total_desks      int NOT NULL,
 "office_space-sqm" bigint NOT NULL,
 CONSTRAINT PK_1a PRIMARY KEY ( office_id )
);

CREATE VIEW vw_optimum_co2 AS
SELECT co2.year
     , co2.month
     , co2.office_id
     , co2.co2_ppm
     , co2.co2_ppm/conf.no_of_floors AS co2_ppm_per_floor
     , conf."office_space-sqm"/conf.total_desks AS space_per_desk
     , co2.co2_ppm / opts.total_people AS co2_per_person
     , FLOOR(opts.total_people / conf.total_desks) AS optimum_floors
     , FLOOR(opts.total_people / conf.total_desks)*(co2.co2_ppm/conf.no_of_floors) AS optimum_co2_usage
FROM "public".office_elec_and_gas_co2 co2
    LEFT JOIN "public".office_configuration conf
        ON co2.office_id = conf.office_id
    LEFT JOIN (SELECT year, 
                      month, 
                      office_id,
                      COUNT(*) as floors_used,
                      SUM(people_per_floor) as total_people
               FROM "public".occupancy_options 
               GROUP BY year, month, office_id) opts
        ON co2.year = opts.year
        AND co2.month = opts.month
        AND co2.office_id = opts.office_id;
