# Trabajo integrador

Para el trabajo integrador se plantea realizar un sistema en solidity con las siguientes características:

* Cada usuario del sistema tiene una billetera en el mismo.
* Estos usuarios pueden comprar el token del sistema (Ozs).
* Pueden usar el token para comprar cartas. Las cartas son generadas de forma aleatoria. 
* Cada usuario tiene la opción de transferir su carta a otro usuario.
* Cada usuario puede ofrecer su carta en una subasta. 

## Token personal

El sistema tiene un token personalizado llamado Oz (ver el nombre). 

## Cartas

En el sistema hay cartas especiales que son adquiridas por los usuarios a cambio del token.

## Usuarios

Las personas que quieran participar del sistema deben adquirir el token y utilizarlo como forma de pago para adquirir los diferentes tipos de cartas.

## Compra de cartas

Se paga una cantidad fija de tokens y se obtiene una carta generada de forma aleatoria. Esta carta le pertenece a la persona que realizo la compra.

## Transferencia

Un usuario puede transferir el ownership de cualquiera de sus cartas a otro usuario del sistema. Para esto la persona que quiere el bien debe transferir una cantidad determinada de tokens, al recibirlos, la persona que posee el bien transfiere el ownership al nuevo dueño.

## Subasta

Para participar de la subasta los usuarios tienen que adquirir Ozs antes de que comience. Una vez que la subasta inicia no se pueden adquirir Ozs. Los participantes de la subasta ofrecen Ozs en orden, siempre superando la oferta anterior. Los tokens ofrecidos por estos usuarios se retienen momentaneamente. Una vez que no hay ofertas por un período de tiempo (3 minutos), se cierra la subasta y nadie mas puede ofertar. Gana la subasta la persona que hizo la oferta mas alta. Los tokens de las personas que perdieron son devueltos, mientras que los tokens ofrecidos por la persona ganadora se retienen como forma de pago y se le entrega a dicha persona la carta subastada.

# Bibliotecas externas

## Ownable

Cuando un método es `external`, toda persona con acceso al contrato lo puede ejecutar. Pero hay métodos que no deberían poder ser ejecutados por cualquier persona. Para solucionar este problema de seguridad se hace uso de un contrato de `OpenZeppelin`, llamado `Ownable`. Nuestro contrato hereda de `Ownable`, lo cual lo convierte en un contrato ownable, quien sea dueño de ese contrato (nosotros) va a tener privilegios especiales.

OpenZeppelin es una biblioteca segura donde hay contratos inteligentes para uso público. En nuestro caso decidimos hacer uso de `Ownable` para corregir esta cuestiön de seguridad.