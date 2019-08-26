## Vulnerable Code

```javascript
function isValid(address _ad) internal view returns(bool) {
        uint endTime = acceptedTokens[_ad].validUntil;
        if (block.timestamp < endTime) return true; //Vulnerable position
        return false;
    }
```



## Exploit Code

```javascript

```



##  Sophisticated Vulnerability Description
Note the location of comment of vulnerability position.As we all know manners can change the value of block.timestamp.To a certain extent, the location of comment of vulnerability position is danger
