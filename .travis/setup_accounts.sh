#!/bin/bash

set -ev

"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
alter user sys identified by admin;
alter user system identified by admin;
alter database default tablespace USERS;
CREATE USER scenic_oracle_adapter IDENTIFIED BY scenic_oracle_adapter;
GRANT unlimited tablespace, create session, create table, create sequence,
create procedure, create trigger, create view, create materialized view,
create database link, create synonym, create type, ctxapp TO scenic_oracle_adapter;
exit
SQL
