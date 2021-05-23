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

## Sintaxis

* Las líneas se finalizan con ';'. 
* Se usan llaves para indicar bloques de código.

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


### Contratos

Para crear un contrato se usa la palabra reservada `contract` de la siguiente manera:

```
contract MiContrato {
    // Datos del contrato
}
```

Los contratos generados son de acceso público para les usuarios del blockchain.