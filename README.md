# teoria-del-lenguaje
Repositorio de Teoría del Lenguaje - FIUBA

# Lenguaje: Solidity

# Links utiles

Documentación: https://solidity-es.readthedocs.io/es/latest/

Videos: https://www.youtube.com/watch?v=MnSmc7Hto2k

Remix: https://remix.ethereum.org/#optimize=false&runs=200&evmVersion=null&version=soljson-v0.8.1+commit.df193b15.js

# Características de Solidity

## General

Solidity es un lenguaje de alto nivel orientado a contratos. Está enfocado específicamente a la Máquina Virtual de Etehreum (EVM).

## Tipado

Es de tpado estático. Es decir que hay que especificar el tipo de dato de las variables que se declaren de forma estática, estos luego serán compilados, y en caso de que en tiempo de ejecución se le pase un tipo de dato distinto, la ejecución fallará.

## Herencia

Acepta Herencia.

## Bibliotecas

Acepta bibliotecas

## Tipos complejos

Acepta tipos complejos definidos por les usuarios.

## Usos

Es posible crear contratos para votar, para el crowdfunding, para subastas a ciegas, para monederos muti firmas, y mucho más.


## Sintaxis

* Las líneas se finalizan con `;`. 
* Se usan llaves para indicar bloques de código.

### Contratos

Para crear un contrato se usa la palabra reservada `contract` de la siguiente manera:

```
contract MyContract {
    // Datos del contrato
}
```

Los contratos generados son de acceso público para les usuarios del blockchain.

### Constructor

El contrato puede tener un constructor. Para esto se debe usar la palabra reservada `constructor` de la siguiente manera:

```
contract MyContract {
    string value;

    constructor() public {
        value = "my value";
    }
}
```

Cada vez que el contrato se deploye, o sea creado, se va a tener value con el valor default "my value".

### Variables de estado

Las `Variables de estado` se guardan permanentemente en el almacenamiento del contrato. Esto significa que se escriben en la cadena de bloques de Ethereum.

Estas variables pueden declararse con visibilidad publica. Solidity crea automáticamente un `getter`para obtener su valor. Este puede ser usado por cualquier persona que tenga acceso al contrato en la Blockchain.

tambein pueden ser creadas inicializadas.

### Tipos de dato nativos

* `uint`: entero sin signo. Se indica la cantidad de bits del uint usando un número múltiplo de 8 hasta 256. Por ejemplo, uint8 es un entero sin signo de 8 bits. uint es por default uint256.

* `int`: entero con signo

* `string`: cadena de texto UTF-8 de longitud variable

### Operaciones matematicas

* `Suma`: x + y
* `Resta`: x - y,
* `Multiplicación`: x * y
* `División`: x / y
* `Módulo`: x % y 
* `Operador exponencial`: x ** y;

### Tipos de datos mas complejos

Para definir un tipo de dato mas complejo se usan los `Structs`. Para esto se usa la palabra reservada `struct`, se indica el nombre del tipo de dato, y los parametros que tendra.

```
struct Carta {
  uint numero;
  string descripción;
}
```

En este ejemplo se define un tipo de dato llamado `Carta` que tiene como parámetros un entero sin signo llamado número y un string que contiene la descripción.

### Arreglos

Cuando se quiere una colección de algun tipo de dato usamos se usan `arreglos`, estos pueden ser de longitud fija o dinámica.

```
// Un Array con una longitud fija de 2 elementos de tipo uint:
uint[2] arregloFijoDeUints;
// otro Array fijo, con longitud fija de 5 elementos de tipo string:
string[5] arregloFijoDeStrings;
// un Array dinámico, sin longitud fija que puede seguir creciendo:
uint[] arregloDinamico;
// un arreglo dinamico de una estructura compleja:
Carta[] aregloDeCartas;
```

Si se declara al arreglo como público, Solidity crea un `getter` para acceder al mismo.

### Funciones

Para escribir una función, se usa la palabra reservada `function`. Se puede especificar una visibilidad (publica o privada) y el tipo de dato que devuelve.

Por ejemplo:

```
contract MyContract {
    string value;

    function get() public return(string) {
        return value;
    }
}
```

A su vez, la función puede recibir parámetros, a los cuales se les debe indicar el tipo de dato.

```
contract MyContract {
    string value;

    function set(string _value) public return(string) {
        value = _value;
    }
}
```

En este caso, el valor que recibe la función comienza con `_` para indicar que no es la variable `value` del contrato. 