// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Contract for EIP20 standard interface
// Reference: https://eips.ethereum.org/EIPS/eip-20
abstract contract IERC20 {
    function balanceOf(address _owner) external virtual view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external virtual returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function approve(address _spender, uint256 _value) external virtual returns (bool success);
    function allowance(address _owner, address _spender) external virtual view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


// Implemetation of ERC20 token
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    string public name = "";
    string public symbol = "";
    uint256 public totalSupply;

    mapping (address => uint256) private balances;
    mapping (address => mapping( address => uint256)) private allowed;
    uint8 public constant decimals = 18;

    /**
    * @dev Constructor, can only set once so set carefully
    */
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        balances[msg.sender] = 100*10**18;
        totalSupply = totalSupply.add(100*10**18);
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) external override view returns (uint256){
        return balances[_owner];
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) external override returns (bool){
        require(balances[msg.sender] >= _value, "Sender not have enough token to transfer");
        require(_to != address(0), "The addresss to transfer to must not be address zero");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool){
        uint256 approvedAmount = allowed[_from][msg.sender];
        require(approvedAmount >= _value, "Sender not have enough approved amount of token to transfer");
        require(balances[_from] >= _value);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    
    /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
    function approve(address _spender, uint256 _value) external override returns (bool){
        require(balances[msg.sender] >= _value, "Sender not have enough token to transfer");
        require(_spender != address(0));

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        
        return true;

    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return remaining A uint256 specifying the amount of tokens still available for the spender.
    * Description from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20.sol
    */
    function allowance(address _owner, address _spender) external override view returns (uint256){
        return allowed[_owner][_spender];
    }


    /**
   * @dev External function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _amount The amount that will be created.
   */
    function mint(uint256 _amount) external {
        _mint(msg.sender, _amount);
    }

    /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _account The account that will receive the created tokens.
   * @param _amount The amount that will be created.
   */
    function _mint(address _account, uint256 _amount) internal {
        require(_account != address(0));
        balances[_account] = balances[_account].add(_amount);
        totalSupply = totalSupply.add(_amount); 
        emit Transfer(address(0), _account, _amount);
    }

    /**
   * @dev External function that burns an amount of the token
   * @param _amount The amount that will be burnt.
   */
    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }

    /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
    function _burn(address _account, uint256 _amount) internal {
        require(_account != address(0));
        require(balances[_account] >= _amount);        
        balances[_account] = balances[_account].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        emit Transfer(_account, address(0), _amount); 
        
    }

    /**
   * @dev External function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
    function burnFrom(address _account, uint256 _amount) external {
        _burnFrom(_account, _amount);
    }

    /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
    function _burnFrom(address _account, uint256 _amount) internal {
        /*  MY OLD CODE */
        // require(account != address(0)); 
        // require(allowed[account][msg.sender] >= amount);
        // require(balances[account] >= amount);
        // balances[account] -= amount;
        // allowed[account][msg.sender] -= amount;
        // totalSupply -= amount;
        // emit Transfer(account, address(0), amount); 

        // Learn from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20.sol
        require(allowed[_account][msg.sender] >= _amount);
        allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);
        _burn(_account, _amount);
    }
}