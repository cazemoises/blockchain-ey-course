// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

// Contrato na sepolia: 0xf4c0ED5073689D029E973cB31C2125F89aa36F7e
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MeuErc20 {

    function obtemSaldo(address tokenAddress, address carteira) public view returns (uint) {

        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(carteira); 
        
    }

    function saldoTotal(address tokenAddress) public view returns (uint) {
        
        IERC20 token = IERC20(tokenAddress);
        return token.totalSupply();
        
    }

}
