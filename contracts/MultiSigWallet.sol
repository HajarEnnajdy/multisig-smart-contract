// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * MultiSigWallet
 * ==============
 * A shared wallet where multiple owners must agree before
 * any money can be sent. Think of it like a bank account
 * that requires 2 out of 3 managers to sign a cheque.
 *
 * The 4 actions any owner can take:
 *   1. submit()  → propose a new transaction
 *   2. approve() → vote YES on a transaction
 *   3. revoke()  → take back your YES vote
 *   4. execute() → send the money (once enough votes collected)
 */
contract MultiSigWallet {

    // ─────────────────────────────────────────
    // EVENTS
    // Blockchain logs. Like a receipt printer —
    // every important action gets recorded here.
    // ─────────────────────────────────────────

    // Fired when someone sends ETH into the wallet
    event Deposit(address indexed sender, uint amount);

    // Fired when an owner proposes a new transaction
    event Submit(uint indexed txId);

    // Fired when an owner approves a transaction
    event Approve(address indexed owner, uint indexed txId);

    // Fired when an owner takes back their approval
    event Revoke(address indexed owner, uint indexed txId);

    // Fired when a transaction is finally executed (money sent)
    event Execute(uint indexed txId);


    // ─────────────────────────────────────────
    // DATA STRUCTURE
    // A "Transaction" is like a pending cheque.
    // It holds all the info about a proposed transfer.
    // ─────────────────────────────────────────

    struct Transaction {
        address to;      // Who should receive the ETH?
        uint value;      // How much ETH (in wei, 1 ETH = 1e18 wei)?
        bytes data;      // Extra data — empty (0x) for simple transfers
        bool executed;   // Was this transaction already sent? true/false
    }


    // ─────────────────────────────────────────
    // STATE VARIABLES
    // Stored permanently on the blockchain.
    // ─────────────────────────────────────────

    // The list of all owner addresses
    address[] public owners;

    // A map: given an address, is it an owner? (true/false)
    // Faster than looping through the owners array every time
    mapping(address => bool) public isOwner;

    // How many approvals are needed before executing (e.g. 2 out of 3)
    uint public required;

    // The full history of every transaction ever submitted
    Transaction[] public transactions;

    // Tracks who approved what:
    // approved[transactionId][ownerAddress] = true or false
    mapping(uint => mapping(address => bool)) public approved;


    // ─────────────────────────────────────────
    // MODIFIERS
    // Reusable checks. The "_;  " means
    // "now run the actual function".
    // ─────────────────────────────────────────

    // Only an owner can call this function
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    // The transaction ID must exist
    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "Tx does not exist");
        _;
    }

    // The caller must not have already approved this transaction
    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "Already approved");
        _;
    }

    // The transaction must not have been executed yet
    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "Already executed");
        _;
    }


    // ─────────────────────────────────────────
    // CONSTRUCTOR
    // Runs once when the contract is deployed.
    // Sets up the owners and the required threshold.
    // ─────────────────────────────────────────

    constructor(address[] memory _owners, uint _required) {
        // Must have at least one owner
        require(_owners.length > 0, "Need at least one owner");

        // required must be between 1 and the total number of owners
        require(
            _required > 0 && _required <= _owners.length,
            "Bad required count"
        );

        // Register each owner one by one
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            // Reject zero address (it's like a null pointer)
            require(owner != address(0), "Zero address not allowed");

            // Reject duplicate owners
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }


    // ─────────────────────────────────────────
    // RECEIVE ETH
    // This special function runs automatically
    // when someone sends ETH to this contract address.
    // ─────────────────────────────────────────

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }


    // ─────────────────────────────────────────
    // THE 4 MAIN FUNCTIONS
    // ─────────────────────────────────────────

    // STEP 1 — An owner proposes sending ETH somewhere
    function submit(address _to, uint _value, bytes calldata _data)
        external
        onlyOwner
    {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        }));
        emit Submit(transactions.length - 1);
    }

    // STEP 2 — An owner votes YES on a pending transaction
    function approve(uint _txId)
        external
        onlyOwner
        txExists(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    // OPTIONAL — An owner takes back their YES vote
    function revoke(uint _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(approved[_txId][msg.sender], "Not approved by you");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    // STEP 3 — Anyone triggers the actual transfer once threshold is met
    function execute(uint _txId)
        external
        txExists(_txId)
        notExecuted(_txId)
    {
        require(_getApprovalCount(_txId) >= required, "Not enough approvals");

        Transaction storage t = transactions[_txId];

        // Mark as executed BEFORE sending the ETH.
        // This prevents "re-entrancy attacks" where a malicious
        // contract could call execute() again during the transfer.
        t.executed = true;

        (bool success, ) = t.to.call{value: t.value}(t.data);
        require(success, "Transfer failed");

        emit Execute(_txId);
    }


    // ─────────────────────────────────────────
    // PRIVATE HELPER
    // Only used internally by execute().
    // Counts how many owners approved a given tx.
    // ─────────────────────────────────────────

    function _getApprovalCount(uint _txId)
        private
        view
        returns (uint count)
    {
        for (uint i = 0; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count++;
            }
        }
    }
}
