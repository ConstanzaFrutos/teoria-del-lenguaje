# Uso de herramientas

## Truffle

### Inicializar proyecto

Para inicializar un proyecto se debe ejecutar el comando:

`truffle init`

### Compilar

Para compilar un contrato se ejecuta el comando:

`truffle compile`

### Migraciones

Se debe crear un archivo en la carpeta `/migrations` con la migracion del contrato. Teniendo Ganache levantado, puesto que es necesario contar con una Blockchain. En Ganache se debe crear el workspace. Para esto se agrega este proyecto, seleccionando el archivo truffle-config, se crea el workspace en ganache, y luego se puede ejecutar la migración. Luego se debe correr el comando:

`truffle migrate`

## Prueba manual con truffle

Primero se debe iniciar la consola:

`truffle console`

Luego se crea la instancia del contrato:

`cartaFactory = await CartaFactory.deployed()`

Finalmente se puede llamar a sus metodos:

`carta = await cartaFactory.crearCartaAleatoria()`

`cartas = await cartaFactory.cartas(0)`

Solidity genera de forma automática los getters de las variables publicas (como el arreglo de cartas).