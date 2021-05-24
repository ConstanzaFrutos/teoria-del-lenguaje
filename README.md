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