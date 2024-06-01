-- MODULE I - Creating a Table
/*
To create a table, you need to define three things:
    - Its name
    - Its columns
    - The data types of these columns
*/
create table categoria(
    id_categoria int,
    nombre VARCHAR2(100)
)

-- MODULE II - Viewing Table Information
select table_name, -- El nombre de la tabla
       iot_name, -- El nombre del índice organizado por tabla (IOT). 
       iot_type, -- El tipo de índice organizado por tabla.
       external, -- Indica si la tabla es una tabla externa (si reside fuera de la base de datos y se accede a ella mediante un archivo)
       partitioned, -- Indica si la tabla está particionada, Lo que significa que los datos de la tabla se dividen en segmentos más pequeños para mejorar el rendimiento y la gestión.
       temporary, -- Indica si la tabla es una tabla temporal
       cluster_name -- El nombre del clúster al que pertenece la tabla
from   user_tables;

-- MODULE III - Try It!
/*
Complete the following statement to create a table to store the following details about bricks:
    - Colour
    - Shape
Use the data type varchar2(10) for both columns.
*/
create table bricks(
    colour VARCHAR2(10),
    shape VARCHAR2(10)
)

select table_name
from user_tables
where table_name='BRICKS';

-- MODULE IV - TABLE ORGANIZATION
/*
Create table in Oracle Database has an organization clause. This defines how it physically stores rows in the table.
The options for this are:
    - Heap
    - Index
    - External
By default, tables are heap-organized. This means the database is free to store rows wherever there is space. You can add 
the "organization heap" clause if you want to be explicit:
*/
create table toys_heap(
    toy_name VARCHAR2(100)
)organization heap;

select table_name, -- El nombre de la tabla
       iot_name, -- El nombre del índice organizado por tabla (IOT). 
       iot_type, -- El tipo de índice organizado por tabla.
       external, -- Indica si la tabla es una tabla externa (si reside fuera de la base de datos y se accede a ella mediante un archivo)
       partitioned, -- Indica si la tabla está particionada, Lo que significa que los datos de la tabla se dividen en segmentos más pequeños para mejorar el rendimiento y la gestión.
       temporary, -- Indica si la tabla es una tabla temporal
       cluster_name -- El nombre del clúster al que pertenece la tabla
from user_tables
where table_name='TOYS_HEAP'

-- MODULE V - INDEX-ORGANIZED TABLES
/*
Unlike a heap table, an index-organized table (IOT) imposes order on the rows within it. It physically stores rows sorted by its primary key.
To create an IOT, you need to:
    - Specify a primary key for the table
    - Add the organization index clause at the end
*/
create table toys_io (
    id_toys integer primary key,
    name_toys varchar2(100)
) organization index;

select table_name,iot_type
from user_tables
where table_name='TOYS_IO'

-- MODULE VI - Try It!
/*Complete the following statement to create the index-organized table bricks_iot:*/
create table bricks_iot(
    bricks_id integer primary key
) organization index;

select table_name,iot_type
from user_tables
where table_name='BRICKS_IOT'

-- MODULE VII - EXTERNAL TABLES
/*
You use external tables to read non-database files on the database server. For example, comma-separated values (CSV) files. To do this, 
you need to:
    - Create a directory pointing to the location of the file on the server
    - Use the organization external clause
    - State the directory and name of the file you want to read
*/
create or replace directory toy_dir as '/path/to/file';

create table toys_ext(
    toy_name varchar2(100)
) organization external(
    default directory tmp 
    location ('toys.csv')
);

-- MODULE VIII - TEMPORARY TABLES
/*
Temporary tables store session specific data. Only the session that adds the rows can see them. This can be handy to store working data.
There are two types of temporary table in Oracle Database: global and private.
*/
    /* Global Temporary Tables
       To create a global temporary table add the clause "global temporary" between create and table. For example:*/
    create global temporary table toys_gtt(
        toys_name varchar2(50)
    )
    -- The definition of the temporary table is permanent. All users of the database can access it. But only your session can view rows 
    -- you insert.
    
    /* Private Temporary Tables
       Starting in Oracle Database 18c, you can create private temporary tables. These tables are only visible in your session. Other 
       sessions can't see the table!
       To create one use "private temporary" between create and table. You must also prefix the table name with ora$ptt_:
    */
    create private temporary table ora$ptt_toys(
        toy_name varchar2(100)
    )
/*
For both temporary table types, by default the rows disappear when you end your transaction. You can change this to when your session ends 
with the "on commit" clause. But either way, no one else can view the rows. Ensure you copy data you need to permanent tables before your 
session ends!
*/
    // Viewing Temporary Table Details
    -- The column temporary in the *_tables views tell you which tables are temporary:
    select table_name,temporary
    from user_tables
    where table_name in ('TOYS_GTT','ORA$PTT_TOYS');
    -- Note that you can only see a row for the global temporary table. The database doesn't write private temporary tables to the data 
    -- dictionary!

-- MODULE IX - PARTITIONING TABLES
/*
Partitioning logically splits up a table into smaller tables according to the partition column(s). So rows with the same partition key are 
stored in the same physical location.
There are three types of partitioning available:
    - Range
    - List
    - Hash

To create a partitioned table, you need to:
    - Choose a partition method
    - State the partition columns
    - Define the initial partitions
The following statements create one table for each partitioning type:
*/

create table toys_range(
    toy_name varchar2(100)
) partition by range (toy_name)(
    partition p0 values less than ('b'),
    partition p1 values less than ('c')
);

create table toys_list(
    toys_name varchar2(100)
) partition by list (toys_name)(
    partition l0 values ('Sir Stripypants'),
    partition l1 values ('Miss Snuggles')
);

create table toys_hash(
    toys_name varchar2(100)
) partition by hash (toys_name) partitions 4;

    -- By default a partitioned table is heap-organized. But you can combine partitioning with some other properties. For example, you can have a 
    -- partitioned IOT:

create table toys_part_iot(
    toy_id integer primary key,
    toy_name varchar2(100)
) organization index
  partition by hash (toy_id) partitions 4;
  
    -- The database sets the partitioned column of *_tables to YES if the table is partitioned. You can view details about the partitions in the 
    -- *_tab_partitions tables:
select table_name,partitioned
from user_tables
where table_name in ('TOYS_RANGE','TOYS_LIST','TOYS_HASH','TOYS_PART_IOT')

    -- Note that partitioning is a separately licensable option of Oracle Database. Ensure you have this option before using it!

-- MODULE X - Try It!
-- Complete the following statement to create a hash-partitioned table. This should be partitioned on brick_id and have 8 partitions:
create table bricks_hash(
   brick_id integer  
)partition by hash (brick_id) partitions 8;

select table_name, partitioned 
from   user_tables
where  table_name = 'BRICKS_HASH';

-- MODULE 11 - TABLE CLUSTERS
/*
A table cluster can store rows from many tables in the same physical location. To do this, first you must create the cluster:
*/
create cluster toy_cluster(
    toy_name varchar2(100)
)
    -- Then place your tables in it using the cluster clause of create table:
    create table toys_cluster_tab(
        toy_name varchar2(100)
    ) cluster toy_cluster (toy_name);
    
    create table toy_owners_cluster_tab(
        toy_owner varchar2(100),
        toy_name varchar2(100)
    )cluster toy_cluster (toy_name);
/*
- Rows that have the same value for toy_name in toys_clus_tab and toy_owners_clus_tab will be in the same place. This can make it faster to get a 
row for a given toy_name from both tables.
- You can view details of clusters by querying the *_clusters views. If a table is in a cluster, cluster_name of *_tables tells you which cluster 
it is in:
*/

select cluster_name from user_clusters;

select table_name, cluster_name
from   user_tables
where  table_name in ( 'TOYS_CLUSTER_TAB', 'TOY_OWNERS_CLUSTER_TAB' );
-- Note: Clustering tables is an advanced topic. They have some restrictions. So make sure you read up on these before you use them!

-- MODULE 12 - DROPPING TABLES
/*
You can remove existing tables with the drop table command. Just add the name of the table you want to destroy:
*/
select table_name
from user_tables
where table_name='TOYS_HEAP'

DROP TABLE TOYS_HEAP

select table_name
from user_tables
where table_name='TOYS_HEAP'    

/* Once you've dropped a table you can't access it. So take care with this command!*/

-- MODULE 13 - Try It!
/*Complete the following statement to drop the toys table:*/

create table toys(
    toy_name varchar2(100)
)

DROP TABLE toys;

select table_name
from user_tables
where table_name='TOYS'
    
    

    