// SPDX-License-Identifier: CC-BY-4.0

pragma solidity 0.8.19;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// @title Manages the contract owner
contract Ownable {
    address payable contractOwner;

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "only owner can perform this operation");
        _;
    }

    constructor() { 
        contractOwner = payable(msg.sender); 
    }
    
    function whoIsTheOwner() public view returns(address) {
        return contractOwner;
    }

    function changeOwner(address _newOwner) onlyOwner public returns (bool) {
        require(_newOwner != address(0x0), "only valid address");
        contractOwner = payable(_newOwner);
        return true;
    }
    
}

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
