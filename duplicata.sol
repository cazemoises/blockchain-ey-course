// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "./owner.sol";
import "./titulo.sol";

contract Duplicata is Owner, Titulo {
    
    string public denominacao;
    uint256 public numero;
    string public emitente;
    uint256 public valor;
    uint256 public vencimento;
    string public descricao;
    
    constructor(
        string memory _denominacao,
        uint256 _numero,
        string memory _emitente,
        uint256 _valor,
        uint256 _vencimento,
        string memory _descricao
    ) {
        denominacao = _denominacao;
        numero = _numero;
        emitente = _emitente;
        valor = _valor;
        vencimento = _vencimento;
        descricao = _descricao;
    }
    
    function valorNominal() external view override returns (uint256) {
        return valor;
    }

    function nomeEmissor() external view override returns (string memory) {
        return emitente;
    }

    function dataEmissao() external view override returns (uint256) {
        return block.timestamp;
    }
}