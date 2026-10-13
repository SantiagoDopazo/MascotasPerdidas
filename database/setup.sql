-- Ejecutar con psql como administrador sobre la base postgres:
-- psql -h localhost -p 5432 -U postgres -d postgres -v ON_ERROR_STOP=1 -f database/setup.sql
-- Solo para una instalacion nueva: el usuario y la base no deben existir.
-- psql solicita la nueva password de mascotas_app sin guardarla en este archivo.
-- No ejecutar este script en Query Tool de pgAdmin: \password es un comando de psql.
CREATE ROLE mascotas_app LOGIN;
\password mascotas_app
CREATE DATABASE mascotas_perdidas OWNER mascotas_app;
