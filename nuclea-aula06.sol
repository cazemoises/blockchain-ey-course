// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ItemRegistry
 * @dev Registro de itens utilizando um mapping e eventos.
 */

 // Contrato implementado na rede Sepolia com o endereço 0x03C633143b3fdD5a64F99777027d67D4a79DEbC9
contract ItemRegistry {

    event ItemAdded(uint256 itemId, string itemName);
    event ItemRemoved(uint256 itemId);

    mapping(uint256 => string) private itemRegistry;

    /**
     * @dev Adiciona um novo item ao registro.
     * @param itemId Identificador único para o item.
     * @param itemName Nome do item a ser registrado.
     */
    function addItem(uint256 itemId, string memory itemName) public {
        itemRegistry[itemId] = itemName;
        emit ItemAdded(itemId, itemName);
    }

    /**
     * @dev Recupera o nome de um item com base no seu ID.
     * @param itemId Identificador do item.
     * @return itemName Nome do item registrado.
     */
    function getItem(uint256 itemId) public view returns (string memory itemName) {
        return itemRegistry[itemId];
    }

    /**
     * @dev Remove um item do registro.
     * @param itemId Identificador do item a ser removido.
     */
    function removeItem(uint256 itemId) public {
        delete itemRegistry[itemId];
        emit ItemRemoved(itemId);
    }
}