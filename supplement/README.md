# Supplement Materials

In this section, we provide concrete information about vulnerable code which is reported by tools. The locations of vulnerable code, our validation results, tools which reported this code are given.

The structure of our data is managed like this:

```
+---Reentrancy
|   +---Doublade
|   +---Oyente
|   +---Securify
|   \---Slither
|       \---Slither
+---Selfdestruct
|   +---Doublade
|   \---Slither
+---source_code
|   \---.vscode
+---Tx-origin
|   +---Doublade
|   +---Slither
|   \---Smartcheck
+---Unchecked_LLC
|   +---Doublade
|   +---Slither
|   \---Smartcheck
\---Unexpected_Revert
    +---Doublade
    +---Slither
    \---Smartcheck
```

Original Solidity code are putted is folder `source_code`. The files are not named with their deployment addresses, rather, we renamed them for experiment convenience. We also provide the address table `address.xlsx` where you can match file names with real addresses.

