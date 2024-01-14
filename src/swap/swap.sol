// Import the Solidity version
pragma solidity ^0.6.12;

// Import the OpenZeppelin library for safe math operations
import "@openzeppelin/contracts/math/SafeMath.sol";

// Import the ERC20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TokenSwap
 * @dev This contract facilitates the swapping of one ERC-20 token for another at a predefined exchange rate.
 */
contract TokenSwap {
   using SafeMath for uint256;

   // The address of the token A
   IERC20 public tokenA;
   // The address of the token B
   IERC20 public tokenB;
   // The exchange rate between Token A and Token B
   uint256 public rate;

   /**
    * @dev Event that is emitted when a swap occurs.
    */
   event Swapped(address indexed account, uint256 amount);

   /**
    * @dev Constructor that sets the initial state of the contract.
    * @param _tokenA The address of Token A.
    * @param _tokenB The address of Token B.
    * @param _rate The initial exchange rate between Token A and Token B.
    */
   constructor(IERC20 _tokenA, IERC20 _tokenB, uint256 _rate) {
       tokenA = _tokenA;
       tokenB = _tokenB;
       rate = _rate;
   }

   /**
    * @dev Swaps Token A for Token B.
    * @param amount The amount of Token A to swap.
    */
   function swapTokenAToTokenB(uint256 amount) public {
       // Check that the user has enough Token A
       require(tokenA.balanceOf(msg.sender) >= amount, "Not enough Token A to swap");

       // Calculate the amount of Token B to receive
       uint256 amountToReceive = amount.mul(rate);

       // Transfer the Token A from the user to this contract
       require(tokenA.transferFrom(msg.sender, address(this), amount), "Transfer of Token A failed");

       // Transfer the Token B from this contract to the user
       require(tokenB.transfer(msg.sender, amountToReceive), "Transfer of Token B failed");

       // Emit the Swapped event
       emit Swapped(msg.sender, amount);
   }

   /**
    * @dev Swaps Token B for Token A.
    * @param amount The amount of Token B to swap.
    */
   function swapTokenBToTokenA(uint256 amount) public {
       // Check that the user has enough Token B
       require(tokenB.balanceOf(msg.sender) >= amount, "Not enough Token B to swap");

       // Calculate the amount of Token A to receive
       uint256 amountToReceive = amount.div(rate);

       // Transfer the Token B from the user to this contract
       require(tokenB.transferFrom(msg.sender, address(this), amount), "Transfer of Token B failed");

       // Transfer the Token A from this contract to the user
       require(tokenA.transfer(msg.sender, amountToReceive), "Transfer of Token A failed");

       // Emit the Swapped event
       emit Swapped(msg.sender, amount);
   }
}
