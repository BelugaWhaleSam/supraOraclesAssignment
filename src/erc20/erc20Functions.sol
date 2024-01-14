// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Import OpenZeppelin's ERC20 contract
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Import OpenZeppelin's Ownable contract for ownership control
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TokenSale
 * @dev Token sale smart contract for the new blockchain project.
 */
contract TokenSale is Ownable(msg.sender) {
    ERC20 public token;

    // Define parameters for the token sale
    uint256 public presaleCap;
    uint256 public publicSaleCap;

    uint256 public presaleMinContribution;
    uint256 public presaleMaxContribution;

    uint256 public publicSaleMinContribution;
    uint256 public publicSaleMaxContribution;

    uint256 public presaleEndTime;
    uint256 public publicSaleStartTime;
    uint256 public publicSaleEndTime;

    mapping(address => uint256) public presaleContributions;
    mapping(address => uint256) public publicSaleContributions;

    bool public presaleClosed = false;
    bool public publicSaleClosed = false;

    // Define events for logging
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 contribution, bool isPresale);
    event TokensDistributed(address indexed receiver, uint256 amount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    // Define modifiers for function access control
    modifier inPresale() {
        require(block.timestamp < presaleEndTime && !presaleClosed, "Presale is closed");
        _;
    }

    modifier inPublicSale() {
        require(block.timestamp >= publicSaleStartTime && block.timestamp < publicSaleEndTime && !publicSaleClosed, "Public sale is closed");
        _;
    }

    modifier onlyBeforePresale() {
        require(block.timestamp < presaleEndTime, "Presale has ended");
        _;
    }

    modifier onlyAfterPresale() {
        require(block.timestamp >= presaleEndTime, "Presale has not ended");
        _;
    }

    modifier onlyAfterPublicSale() {
        require(block.timestamp >= publicSaleEndTime, "Public sale has not ended");
        _;
    }

    /**
     * @dev Constructor to initialize the TokenSale contract.
     * @param _tokenAddress The address of the deployed ERC-20 token contract.
     * @param _presaleCap The maximum cap on Ether for the presale.
     * @param _publicSaleCap The maximum cap on Ether for the public sale.
     * @param _presaleMinContribution The minimum contribution limit per participant for the presale.
     * @param _presaleMaxContribution The maximum contribution limit per participant for the presale.
     * @param _publicSaleMinContribution The minimum contribution limit per participant for the public sale.
     * @param _publicSaleMaxContribution The maximum contribution limit per participant for the public sale.
     * @param _presaleEndTime The end time of the presale.
     * @param _publicSaleStartTime The start time of the public sale.
     * @param _publicSaleEndTime The end time of the public sale.
     */
    constructor(
        address _tokenAddress,
        uint256 _presaleCap,
        uint256 _publicSaleCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution,
        uint256 _presaleEndTime,
        uint256 _publicSaleStartTime,
        uint256 _publicSaleEndTime
    ) {
        // Set the ERC-20 token contract
        token = ERC20(_tokenAddress);

        // Set other parameters for the token sale
        presaleCap = _presaleCap;
        publicSaleCap = _publicSaleCap;
        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;
        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;
        presaleEndTime = _presaleEndTime;
        publicSaleStartTime = _publicSaleStartTime;
        publicSaleEndTime = _publicSaleEndTime;
    }

    /**
     * @dev Function to allow users to contribute to the presale and receive project tokens.
     * @param amount The amount of Ether to contribute.
     */
    function contributeToPresale(uint256 amount) external inPresale {
        // Check contribution amount and limit
        require(amount >= presaleMinContribution && amount <= presaleMaxContribution, "Invalid contribution amount");
        require(presaleContributions[msg.sender] + amount <= presaleMaxContribution, "Exceeds maximum contribution limit");

        // Check presale cap
        uint256 remainingCap = presaleCap - address(this).balance;
        require(remainingCap >= amount, "Presale cap reached");

        // Update contribution mapping and transfer tokens
        presaleContributions[msg.sender] += amount;
        token.transfer(msg.sender, amount);

        // Log event
        emit TokensPurchased(msg.sender, amount, presaleContributions[msg.sender], true);
    }

    /**
     * @dev Function to allow users to contribute to the public sale and receive project tokens.
     * @param amount The amount of Ether to contribute.
     */
    function contributeToPublicSale(uint256 amount) external inPublicSale {
        // Check contribution amount and limit
        require(amount >= publicSaleMinContribution && amount <= publicSaleMaxContribution, "Invalid contribution amount");
        require(publicSaleContributions[msg.sender] + amount <= publicSaleMaxContribution, "Exceeds maximum contribution limit");

        // Check public sale cap
        uint256 remainingCap = publicSaleCap - address(this).balance;
        require(remainingCap >= amount, "Public sale cap reached");

        // Update contribution mapping and transfer tokens
        publicSaleContributions[msg.sender] += amount;
        token.transfer(msg.sender, amount);

        // Log event
        emit TokensPurchased(msg.sender, amount, publicSaleContributions[msg.sender], false);
    }

    /**
     * @dev Function to allow the owner to distribute project tokens to a specified address.
     * @param recipient The address to receive the tokens.
     * @param amount The amount of tokens to distribute.
     */
    function distributeTokens(address recipient, uint256 amount) external onlyOwner onlyAfterPublicSale {
        // Check recipient address
        require(recipient != address(0), "Invalid recipient address");

        // Transfer tokens to the recipient
        token.transfer(recipient, amount);

        // Log event
        emit TokensDistributed(recipient, amount);
    }

    /**
     * @dev Function to allow contributors to claim a refund if the minimum cap is not reached.
     */
    function claimRefund() external {
        // Check if refund is available
        require(
            (block.timestamp >= presaleEndTime && !presaleClosed) || (block.timestamp >= publicSaleEndTime && !publicSaleClosed),
            "Refund not available yet"
        );

        uint256 refundAmount = 0;

        if (block.timestamp >= presaleEndTime && !presaleClosed) {
            // Refund for presale contributors
            refundAmount = presaleContributions[msg.sender];
            require(refundAmount > 0, "No presale contribution to refund");
            presaleContributions[msg.sender] = 0;
        } else if (block.timestamp >= publicSaleEndTime && !publicSaleClosed) {
            // Refund for public sale contributors
            refundAmount = publicSaleContributions[msg.sender];
            require(refundAmount > 0, "No public sale contribution to refund");
            publicSaleContributions[msg.sender] = 0;
        }

        // Transfer refund to the contributor
        payable(msg.sender).transfer(refundAmount);

        // Log event
        emit RefundClaimed(msg.sender, refundAmount);
    }

    /**
     * @dev Function to allow the owner to close the presale.
     */
    function closePresale() external onlyBeforePresale onlyOwner {
        presaleClosed = true;
    }

    /**
     * @dev Function to allow the owner to close the public sale.
     */
    function closePublicSale() external onlyAfterPublicSale onlyOwner {
        publicSaleClosed = true;
    }
}