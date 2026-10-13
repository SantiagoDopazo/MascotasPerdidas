.DEFAULT_GOAL := start

ifeq ($(OS),Windows_NT)
SHELL := cmd.exe
.SHELLFLAGS := /c
MVNW := .\mvnw.cmd
else
MVNW := sh ./mvnw
endif

.PHONY: setup start test build help

setup:
ifeq ($(OS),Windows_NT)
	@powershell.exe -NoProfile -Command "if (Test-Path -LiteralPath 'config/application-local.properties') { Write-Output 'La configuracion local ya existe; se conserva.' } else { Copy-Item -LiteralPath 'config/application-local.properties.example' -Destination 'config/application-local.properties'; Write-Output 'Configuracion creada. Completar usuario y password en config/application-local.properties.' }"
else
	@if [ -e config/application-local.properties ]; then echo "La configuracion local ya existe; se conserva."; else cp config/application-local.properties.example config/application-local.properties && echo "Configuracion creada. Completar usuario y password en config/application-local.properties."; fi
endif

start:
	$(MVNW) spring-boot:run "-Dspring-boot.run.profiles=local"

test:
	$(MVNW) test

build:
	$(MVNW) package

help:
	@echo "make setup - Preparar la configuracion local sin sobrescribirla"
	@echo "make start - Iniciar el backend con el perfil local"
	@echo "make test  - Verificar la conexion a PostgreSQL"
	@echo "make build - Ejecutar tests y generar el JAR"
