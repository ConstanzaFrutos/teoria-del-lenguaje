# Uso de herramientas

## Instalaciones y versiones

### Web3

Version: 1.0.0-beta.26

Comando: `npm i web3@1.0.0-beta.26`

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

Si se modifica el contrato se debe volver a correr la migracion:

`truffle migrate --reset`

## Prueba manual con truffle

Primero se debe iniciar la consola:

`truffle console`

Luego se crea la instancia del contrato:

`cartaItem = await CartaItem.deployed()`

Finalmente se puede llamar a sus metodos:

`carta = await cartaItem.crearCartaAleatoria()`

`cartas = await cartaItem.cartas(0)`

Solidity genera de forma automática los getters de las variables publicas (como el arreglo de cartas).

### Debugger

Truffle ofrece un debugger integrado. Para acceder al mismo se debe ejecutar el comando:

`truffle debug`

A su vez, se puede debuggear una transaccion especifica:

`truffle debug <numero_transaccion>`

Los comandos son los siguientes:

```
Commands:
(enter) last command entered (step next)
(o) step over, (i) step into, (u) step out, (n) step next
(c) continue until breakpoint, (Y) reset & continue to previous error
(y) (if at end) reset & continue to final error
(;) step instruction (include number to step multiple)
(g) turn on generated sources, (G) turn off generated sources except via `;`
(p) print instruction & state (`p [mem|cal|sto]*`; see docs for more)
(l) print additional source context, (s) print stacktrace, (h) print this help
(q) quit, (r) reset, (t) load new transaction, (T) unload transaction
(b) add breakpoint (`b [[<source-file>:]<line-number>]`; see docs for more)
(B) remove breakpoint (similar to adding, or `B all` to remove all)
(+) add watch expression (`+:<expr>`), (-) remove watch expression (-:<expr>)
(?) list existing watch expressions and breakpoints
(v) print variables and values, (:) evaluate expression - see `v`
```


## Usar OpenZeppelin

Instalacion:

`npm install @openzeppelin/contracts`

https://docs.openzeppelin.com/contracts/3.x/

## Errores

### Invalid solidity type tuple

https://ethereum.stackexchange.com/questions/36229/invalid-solidity-type-tuple

The error lies within the web3-object, not your smart contract. The struct feature is not yet implemented there.

See https://github.com/ethereum/web3.js/issues/1241 where this issue is described.

So basically you can work with solidity-structs when interacting with your contract-functions inside a contract or with a library, but not to pass data from web3 to your contract or to retrieve data from the contract through web3.