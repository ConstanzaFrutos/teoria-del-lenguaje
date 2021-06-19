pragma solidity ^0.5.16;

/**
 * @title Ownable
 * @dev El contrato tiene una dirección del owner y provee control básico de autorización
 * esto simplifica la implementacion de permisos de usuario.
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev El constructor asigna el `owner` original del contrato
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Evita que se ejecute el método por cualquier cuenta que no sea owner del mismo
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Permite que el owner actual transfiera control de la cuenta a un nuevoOwner
   * @param newOwner La direccion a la cual se transfiere el ownership
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
