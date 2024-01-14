// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin's ERC20 contract
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title ERC20 Token Creation
 * @dev ERC-20 token contract for the new blockchain project.
 */
contract MyToken is ERC20 {
    /**
     * @dev Constructor to initialize the ERC-20 token.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 1,000,000 tokens to the contract deployer
        _mint(msg.sender, 1000000 * 10**decimals());
    }
}