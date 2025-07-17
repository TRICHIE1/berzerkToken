// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Berserktoken {
    // ... rest of your contract remains the same
    string public name = "berzerk";
    string public symbol = "BRK";
    uint8 public decimals = 18;
    uint public totalsupply = 100000 * (10 ** 18);
    address public owner;

    function totalSupply() public view returns (uint256) {
        return  totalsupply;
    }

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }
    
    constructor () {
        owner = msg.sender;
        balances[msg.sender] = totalsupply;
    }

    // transfer BRK token
    function transfer(address _recipient, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "not enough balance");
        balances[msg.sender] -= _value;
        balances[_recipient] += _value;
        emit Transfer( msg.sender, _recipient, _value);
        return true;
    }
    
    event Transfer(address indexed from, address indexed to, uint256);
    event Approval(address indexed owner, address indexed spender, uint256);
    
    // approve BRK token
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // allow spender to spend tokens on your behalf?
        allowances[msg.sender][_spender] = _value;
        emit Approval( msg.sender,_spender, _value);
        return true;
    }
    // transfer BRK token on behalf of sender 
    function transferFrom (address _from, address _to, uint256 _value )public returns (bool success) {
        require(balances[_from] >= _value, "not enough balance");
        require(allowances[_from][msg.sender] >= _value , "insufficient allowance");
        
        balances[_from] -= _value; 
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
       
        emit Transfer(_from, _to, _value);
        return true;
    }
    function increaseAllowance(address _spender ,uint256 addedValue)public returns(bool){
        allowances[msg.sender][_spender] += addedValue;
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }
    function decreaseAllowance(address _spender ,uint256 subtractedValue)public returns (bool){
        require(allowances[msg.sender][_spender] >= subtractedValue,"allowance too low");
        allowances[msg.sender][_spender] -= subtractedValue;
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }
}
