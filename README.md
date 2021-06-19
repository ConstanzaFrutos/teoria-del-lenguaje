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

#### Modificadores de funciones

Un modificador de función es igual que una función, pero usa la palabra clave `modifier` en vez de `function`. Los modificadores no pueden llamarse directamente como una función, sino que se usan dentro de una función como si fueran un "decorador". De esta manera, se ejecuta la acción del modificador, y si el resultado es el esperado, se ejecuta la función en cuestion, sino se detiene la ejecución. Un ejemplo de esto es el modificador `onlyOwner` de `Ownable`. Este se agrega a toda función que solo pueda ser ejecutada por el owner del contrato. Si la ejecuta otra persona, hay una excepción y se finaliza la ejecución. 

Sintaxis:

```
modifier onlyOwner() {
  require(msg.sender == owner);
  _;
}

function comprar() external onlyOwner {
    // lo que haga la funcion
}
```

Los modificadores tambien pueden aceptar parámetros.

## Gas

El `Gas` es el combustible que mueven las DApps de Ethereum. En Solidity, tus usuarios tienen que pagar cada vez que ejecuten una función de tu DApp con gas. La divisa de Ethereum es el `Ether`, que se obtiene con plata real. Los usuarios obtienen gas mediante el ether, entonces, al usar nuestros contratos, estan consumiendo ETH.

La cantidad de gas necesaria para ejecutar una función depende de la complejidad de esta. Cada operación individual tiene un coste de gas basado aproximadamente en cuantos recursos computacionales se necesitarán para llevarla a cabo (escribir en memoria es más caro que añadir dos integers). El total coste de gas de tu función es la suma del coste de cada una de sus operaciones.

Dado que los usuarios estan consumiendo dinero al usar nuestros contratos, es importante optimizar el código. Mucho mas importante que en otros lenguajes. 

El gas es necesario, por como esta construída Ethereum. Se lo describe como un ordenador grande, lento, pero extremandamente seguro. Cuando se ejecuta una función, cada uno de los nodos de la red necesita ejecutar esa misma función para comprobar su respuesta - miles de nodos verificando cada ejecución de funciones es lo que hace a Ethereum descentralizado, y que sus datos sean inmutables y resistentes a la censura.

Los creadores de Ethereum querian estar seguros de que nadie pudiese obstruir la red con un loop infinito, o acaparar todos los recursos de la red con cálculos intensos. Por eso no hicieron las transacciones gratuitas, y los usuarios tienen que pagar por su poder de computo así como por su espacio en memoria.

Es importante notar, que tambien hay `sidechains` en las cuales se opera de otra manera, y por eso sistemas que requieran de mucho gas se ejecutaría en una de estas, no en la mainnet de Ethereum. 

Antes se habló de los diferentes tamaños de los `uint` (uint8, uint16, ..., uint256). Usar un uint con menor cantidad de bits a 256 no ahorra gas por si solo. Dado que de todas maneras solidity reserva 256 bits de almacenamiento independientemente del tamaño del uint. Pero hay una excepción, si los uint estan dentro de un struct, solidity los empaqueta de manera de usar menos almacenamiento. Para esto deben agruparse los tipos de dato que sean iguales, así se minimiza el espacio requerido.

```
struct Empaquetado {
  uint32 a;
  uint32 b;
  uint c;
}
```

Los uint32 estan uno al lado del otro en el ejemplo, permitiendo a Solidity optimizar el espacio.
