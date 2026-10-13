# MascotasPerdidas

Es una aplicación web que tiene como objetivo facilitar la búsqueda de perros y gatos perdidos, conectando a personas que buscan a sus mascotas con aquellas que encontraron o avistaron animales.

La plataforma funcionará como una red social donde los usuarios podrán publicar mascotas perdidas o encontradas, consultar publicaciones de otras personas y colaborar para reunir a los animales con sus dueños.

## Entorno del backend

Java 17, Spring Boot 3.5.16, Maven, PostgreSQL 17, Spring Data JPA,
Bean Validation y Actuator.

### 1. Instalar las dependencias

Se necesita **JDK 17**, **PostgreSQL 17**, **Git** y **GNU Make**.
No hace falta instalar Maven: el repositorio incluye Maven Wrapper. La primera
ejecución requiere Internet para descargar Maven y las dependencias Java.

#### Windows

- Instalar un [JDK 17](https://adoptium.net/temurin/releases/?version=17), agregarlo
  al PATH y configurar `JAVA_HOME` con la carpeta del JDK.
- Instalar [PostgreSQL 17](https://www.postgresql.org/download/windows/), guardar
  la contraseña elegida para `postgres` y mantener iniciado el servicio.
- Instalar [Git](https://git-scm.com/downloads). Se puede trabajar desde Git Bash
  o PowerShell en la terminal de VS Code.
- Instalar GNU Make y agregarlo al PATH para ejecutar los comandos del proyecto.

#### macOS

Con [Homebrew](https://brew.sh/) instalado:

```sh
brew install openjdk@17 postgresql@17 git
sudo ln -sfn "$(brew --prefix openjdk@17)/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk-17.jdk
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH="$JAVA_HOME/bin:$(brew --prefix postgresql@17)/bin:$PATH"
brew services start postgresql@17
```

Agregar las líneas `export` a `~/.zshrc` para conservarlas al abrir otra terminal.
Si no está disponible `make`, instalar las herramientas de desarrollo con
`xcode-select --install`.

Referencias: [JDK 17 en Homebrew](https://formulae.brew.sh/formula/openjdk@17) y
[PostgreSQL 17 en Homebrew](https://formulae.brew.sh/formula/postgresql@17).

#### Ubuntu

```sh
sudo apt update
sudo apt install openjdk-17-jdk git make unzip
```

Para disponer de PostgreSQL 17, configurar el repositorio oficial:

```sh
sudo apt install postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
sudo apt update
sudo apt install postgresql-17 postgresql-client-17
sudo systemctl enable --now postgresql
```

Referencia: [instalación oficial para Ubuntu](https://www.postgresql.org/download/linux/ubuntu/).

En cualquier sistema, verificar:

```sh
java -version
javac -version
make --version
```

Los comandos de Java deben indicar Java 17 y `make` debe mostrar su versión.
VS Code e IntelliJ son opcionales; pgAdmin y DBeaver
permiten administrar la base.

### 2. Descargar el proyecto

```sh
git clone https://github.com/SantiagoDopazo/MascotasPerdidasBackend.git
cd MascotasPerdidasBackend
```

Todos los comandos siguientes se ejecutan desde esta carpeta.

### 3. Crear la base local

En pgAdmin, conectarse a `localhost:5432` como `postgres`, seleccionar la base
`postgres` y abrir **Tools → Query Tool**. Elegir una contraseña local para el
usuario de la aplicación. Ejecutar cada sentencia por separado con Auto-commit
activado, reemplazando `TU_PASSWORD_LOCAL`:

```sql
CREATE ROLE mascotas_app LOGIN PASSWORD 'TU_PASSWORD_LOCAL';
CREATE DATABASE mascotas_perdidas OWNER mascotas_app;
```

La creación de la base debe ejecutarse fuera de una transacción.

Como alternativa, crear la base desde la terminal con el script incluido.
En **Windows**, con `psql` disponible en el PATH:

```sh
psql -h localhost -p 5432 -U postgres -d postgres -v ON_ERROR_STOP=1 -f database/setup.sql
```

En **Ubuntu**, usar la autenticación local del usuario del sistema `postgres`:

```sh
sudo -u postgres psql -d postgres -v ON_ERROR_STOP=1 -f - < database/setup.sql
```

En **macOS con Homebrew**, el administrador inicial suele ser el usuario de macOS:

```sh
psql -d postgres -v ON_ERROR_STOP=1 -f database/setup.sql
```

Si PostgreSQL se instaló con otro método, usar su usuario administrador.
El script pide la nueva contraseña de `mascotas_app` dos veces; no se muestra
mientras se escribe. Está pensado para una instalación nueva; no repetirlo si el
usuario y la base ya existen. En Windows, si `psql` no está en el PATH, usar pgAdmin
o el ejecutable de `C:\Program Files\PostgreSQL\17\bin`.

Si ya existe una base y un usuario propios, usar esos datos y omitir la creación.
También se puede conectar con `postgres` en el entorno local, configurando ese
usuario y su contraseña en el paso siguiente.

### 4. Configurar las credenciales

```sh
make setup
```

Crea `config/application-local.properties` sin sobrescribir un archivo existente.

Editar `config/application-local.properties` con la URL, usuario y contraseña reales:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/mascotas_perdidas
spring.datasource.username=mascotas_app
spring.datasource.password=TU_PASSWORD_LOCAL
```

La contraseña debe coincidir con la elegida al crear el usuario en el paso anterior.
Este archivo está ignorado por Git. Spring carga automáticamente la configuración
de `config/` al iniciar desde la raíz con el perfil `local`.

Como alternativa al archivo local, se pueden usar las variables `DB_URL`,
`DB_USERNAME`, `DB_PASSWORD` y `SERVER_PORT`. Si el archivo local define las
propiedades de la conexión, esas propiedades reemplazan los valores del archivo
base; para usar las variables, quitar del archivo local las propiedades de conexión.
Spring Boot no carga archivos `.env` automáticamente.

### 5. Verificar y ejecutar el servidor

Desde la raíz del proyecto (Windows, macOS o Linux):

```sh
make test
make start
```

`make test` ejecuta `SELECT 1` contra PostgreSQL real para verificar la conexión.
Requiere la base creada y las credenciales configuradas. `make start` inicia el
backend con el perfil `local`. Make usa el Maven Wrapper incluido en el repositorio.

Con la aplicación en ejecución, abrir `http://localhost:8080/actuator/health`,
o consultar desde PowerShell:

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health | ConvertTo-Json -Depth 5
```

Debe devolver `status: UP` y, con el perfil local, `components.db.status: UP`.
En Git Bash, macOS o Linux se puede consultar con
`curl http://localhost:8080/actuator/health`.
El backend usa el puerto 8080 y PostgreSQL el 5432 por defecto.
Si falla la autenticación, revisar usuario y contraseña; si se rechaza la conexión,
revisar que PostgreSQL esté iniciado y que la URL tenga el puerto correcto.

### Comandos habituales

| Comando | Acción |
| --- | --- |
| `make setup` | Copiar la plantilla de configuración si aún no existe |
| `make start` | Iniciar el backend en el puerto 8080 |
| `make test` | Ejecutar los tests contra PostgreSQL local |
| `make build` | Ejecutar tests y generar `target/mascotas-perdidas-backend-0.0.1-SNAPSHOT.jar` |
| `make help` | Mostrar los comandos disponibles |

La terminal queda ocupada mientras el backend está iniciado. Detenerlo con
`Ctrl + C`. En Windows, si pregunta si se desea terminar el trabajo por lotes,
responder `S`.

Si el puerto 8080 está ocupado, detener la otra aplicación o agregar
`server.port=8081` a `config/application-local.properties` y consultar el nuevo puerto.
Si aparece `make: command not found`, instalar GNU Make y revisar el PATH.
Si aparece `java: command not found`, revisar la instalación del JDK y el PATH.
Las tablas del dominio se agregarán cuando se implementen las funcionalidades.

### Criterios de diseño

La clase principal está en el paquete `mascotasperdidas`. A medida que se
implementen funcionalidades, separar dominio, casos de uso, persistencia y API.
JPA permite incorporar repositorios e inyección de dependencias; los patrones del
dominio se elegirán según las reglas de negocio del TP.

Hibernate valida el esquema (`ddl-auto=validate`). Por ahora no se crean tablas
del dominio automáticamente; la gestión del esquema se definirá al implementar
las primeras entidades.

## Funcionalidades principales

- COMPELTAR

## Equipo

*
*
*
*
* Santiago Agustin Dopazo

**Materia:** Diseño de Sistemas
**Año:** 2026
