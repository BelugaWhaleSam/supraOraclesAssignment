// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MultiSigWallet
 * @dev A simple multi-signature wallet contract that requires multiple owners to confirm and execute transactions.
 */
contract MultiSigWallet {
    // State variables
    address[] public owners; // List of owners
    uint public numConfirm; // Number of confirmations required for a transaction to be executed

    // Struct to represent a transaction
    struct Transaction {
        address to; // Recipient address
        uint value; // Ether value of the transaction
        bool executed; // Flag indicating whether the transaction has been executed
    }

    // Mapping to track confirmations for each owner and transaction
    mapping(uint => mapping(address => bool)) isConfirmed;

    // Mapping to check if an address is an owner
    mapping(address => bool) isOwner;

    // Array to store transactions
    Transaction[] public transactions;

    // Events
    event TransactionSubmitted(uint transactionId, address sender, address receiver, uint amount);
    event TransactionConfirmed(uint transactionId);
    event TransactionExecuted(uint transactionId);

    // Modifier to check if the caller is an owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    /**
     * @dev Constructor to initialize the MultiSigWallet contract.
     * @param _owners List of owner addresses.
     * @param _numConfirmationRequired Number of confirmations required for a transaction.
     */
    constructor(address[] memory _owners, uint _numConfirmationRequired) {
        require(_owners.length > 1, "Owners required must be greater than 1");
        require(_numConfirmationRequired > 0 && _numConfirmationRequired <= _owners.length, "Num of confirmations not in sync with num of owners");
        numConfirm = _numConfirmationRequired;

        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid Owner");
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
    }

    /**
     * @dev Function to submit a new transaction.
     * @param _to Recipient address.
     */
    function submitTransaction(address _to) public payable {
        require(_to != address(0), "Invalid recipient address");
        require(msg.value > 0, "Transfer amount must be greater than 0");

        uint transactionId = transactions.length;

        transactions.push(Transaction({
            to: _to,
            value: msg.value,
            executed: false
        }));

        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }

    /**
     * @dev Function for owners to confirm a transaction.
     * @param _transactionId Transaction ID to confirm.
     */
    function confirmTransaction(uint _transactionId) public onlyOwner {
        require(_transactionId < transactions.length, "Invalid transaction ID");
        require(!isConfirmed[_transactionId][msg.sender], "Transaction is already confirmed by owner");

        isConfirmed[_transactionId][msg.sender] = true;
        emit TransactionConfirmed(_transactionId);

        if (isTransactionConfirmed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    /**
     * @dev Function to check if a transaction has enough confirmations.
     * @param _transactionId Transaction ID to check.
     * @return True if the transaction has enough confirmations, false otherwise.
     */
    function isTransactionConfirmed(uint _transactionId) public view returns (bool) {
        require(_transactionId < transactions.length, "Invalid transaction ID");
        uint confirmation;
        for (uint i = 0; i < numConfirm; i++) {
            if (isConfirmed[_transactionId][owners[i]]) {
                confirmation++;
            }
        }
        return confirmation >= numConfirm;
    }

    /**
     * @dev Function to execute a transaction.
     * @param _transactionId Transaction ID to execute.
     */
    function executeTransaction(uint _transactionId) public payable {
        require(_transactionId < transactions.length, "Invalid transaction ID");
        require(!transactions[_transactionId].executed, "Transaction is already executed");

        (bool success,) = transactions[_transactionId].to.call{value: transactions[_transactionId].value}("");

        require(success, "Transaction execution failed");
        transactions[_transactionId].executed = true;
        emit TransactionExecuted(_transactionId);
    }
}
