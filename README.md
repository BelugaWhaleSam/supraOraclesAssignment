## Supra Oracles Assignment - Mohd Sameer

I have provided all the code in the forge development framework and code lies in `src` file. The code was tested on remix IDE and is well commented

## Table of Contents

- [ERC-20 Token](#erc-20-token)
- [Voting DAO](#voting-dao)
- [Swap Token](#swap-token)
- [MultiSigWallet](#multisig-wallet)
- [Testing](#testing)
- [Comments](#comments)
- [Usage](#usage)

## ERC-20 Token

The ERC-20 Token contract is located in the `src/erc20` folder. This contract follows the ERC-20 standard and allows for the creation of tokens on the Ethereum blockchain. 

### Explanation
- There is presale, public sale, token distribution and refund functions
- Implements the ERC-20 standard for fungible tokens.
- Supports functions such as `transfer`, `approve`, `transferFrom`, and `totalSupply`.

## Voting DAO

The Voting DAO contract is located in the `src/votingDAO` folder. This contract establishes a simple decentralized autonomous organization (DAO) for voting on proposals.

### Explanation

- Enables owner to register as voters and add candidates.
- Allows voters to submit and confirm transactions.

## Swap Token

The Swap Token contract is located in the `src/swapToken` folder. This contract facilitates token swaps between two parties.

### Explanation

- Implements a basic token swapping mechanism using ERC20.
- Users can initiate swaps by providing the desired token amounts.

## MultiSig Wallet

The MultiSigWallet contract is located in the `src/multisigWallet` folder. This contract implements a multi-signature wallet that requires multiple owners to confirm and execute transactions.

### Explanation

- Requires multiple owners to confirm transactions based on threshold value provided as a parameter in constructor.
- Provides functionality for submitting, confirming, and executing transactions.

## Testing

The code has been partially tested on Remix to ensure basic functionality.

## Comments

The code is well-commented to enhance readability and understanding for reviewers. Please review the inline comments for detailed explanations of each section and function.

## Usage

### Build

```shell
$ cd Desktop
$ mkdir supraAssignment
$ https://github.com/BelugaWhaleSam/supraOraclesAssignment.git
```
You can view the code in src folder for solidity



