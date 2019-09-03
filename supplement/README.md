# Supplement Materials

In this section, we provide concrete information about vulnerable code which is reported by tools. The locations of vulnerable code, our validation results, tools which reported this code are given.

Please download our data on [this](https://drive.google.com/file/d/1k0Edw2r1Z59WBc8SFbeh85hJMydGNPGz/view?usp=sharing). The structure of our data is managed like:

```
+---outputs
|   +---doublade
|   |       doublade_lowlevelcall_output.log
|   |       doublade_reentrancy_output.log
|   |       doublade_selfdestruct_output.log
|   |       doublade_tx_output.log
|   |       doublade_unexpectedrevert_output.log
|   |
|   +---oyente
|   +---securify
|   +---slither
|   \---smartcheck
+---source_code
|	address.xlsx
\---validation_results
|   doublade_lowlevelcall_result.xlsx
|   doublade_reentrancy.xlsx
|   doublade_selfdestruct_result.xlsx
|   doublade_tx_result.xlsx
|   doublade_unexpectedrevert_result.xlsx
|   oyente_reentrancy.xlsx
|   securify_reentrancy.xlsx
|   slither_lowlevelcall_result.xlsx
|   slither_reentrancy.xlsx
|   slither_selfdestruct_result.xlsx
|   slither_tx_result.xlsx
|   slither_unexpectedrevert_result.xlsx
|   smartcheck_lowlevelcall_result.xlsx
|   smartcheck_tx_result.xlsx
|  	smartcheck_unexpectedrevert_result.xlsx
|
```

Original Solidity code are putted is folder `source_code`. The files are not named with their deployment addresses, rather, we renamed them for experiment convenience. We also provide the address table `address.xlsx` where you can match file names with real addresses.

In folder `outputs`, we grouped raw vulnerability detection reports by tools. And the validation results are included in folder `validation_results`. 

Please combine validation results with source code and raw outputs. For further, if you want to look up the value involved in code, you can find addresses by matching file names in `address.xlsx` and search them in [Etherscan](https://etherscan.io/) for details.

