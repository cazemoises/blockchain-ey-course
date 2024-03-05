// SPDX-License-Identifier: CC-BY-4.0
pragma solidity 0.8.19;

import "./ownable.sol";
import "./IERC20.sol";

contract DebentureXPTO is Ownable, IERC20 {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 public immutable decimals = 2;
    uint256 public immutable issueDate;
    uint256 public faceValue = 10000;
    uint256 public maturityPeriod = 2 * 365 days;
    string public rating = "BBB-";

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private ownerAllowances;

    constructor() {
        _name = "XPTO";
        _symbol = "IDXPTO";
        issueDate = block.timestamp;
        _totalSupply = 1000000 * (10 ** uint256(decimals));
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function totalSupply() public view override returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns(uint256) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view override returns(uint256) {
        return ownerAllowances[tokenOwner][spender];
    }

    function transfer(address to, uint256 amount) public override returns(bool) {
        require(balances[msg.sender] >= amount, "Saldo insuficiente");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    } 

    function approve(address spender, uint256 amount) public override returns(bool) {
        ownerAllowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        require(balances[from] >= amount, "Saldo insuficiente");
        require(ownerAllowances[from][msg.sender] >= amount, "Allowance insuficiente");
        balances[from] -= amount;
        balances[to] += amount;
        ownerAllowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function changeRating(string memory newRating) public onlyOwner {
        rating = newRating;
    }

    function mint(uint256 amount) public onlyOwner {
        _totalSupply += amount;
        balances[contractOwner] += amount;
        emit Transfer(address(0), contractOwner, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        require(balances[contractOwner] >= amount, "Saldo insuficiente");
        _totalSupply -= amount;
        balances[contractOwner] -= amount;
        emit Transfer(contractOwner, address(0), amount);
    }
    
}