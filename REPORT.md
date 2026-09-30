# MultiSig Wallet — Complete Project Report

**Solidity · Hardhat · Ganache · No MetaMask · No Remix**

| Property    | Value                                          |
|-------------|------------------------------------------------|
| Contract    | `MultiSigWallet.sol` — Solidity 0.8.13         |
| Network     | Local Ganache (`localhost:7545`, chainId 1337) |
| Deploy tool | Hardhat (replaces Remix IDE)                   |
| Wallet tool | Direct private key signing (replaces MetaMask) |
| Frontend    | Plain HTML + ethers.js v5 (open in browser)    |
| Threshold   | Configurable — e.g. 2 out of 3 owners          |

## Table of Contents

1. [Project Structure](#1-project-structure)
2. [Step-by-Step Setup Guide](#2-step-by-step-setup-guide)
3. [How to Use the Wallet](#3-how-to-use-the-wallet)
4. [The Solidity Contract — Explained](#4-the-solidity-contract--explained)
5. [Hardhat & the Deploy Script](#5-hardhat--the-deploy-script)
6. [The Frontend — index.html](#6-the-frontend--indexhtml)
7. [Key Concepts Glossary](#7-key-concepts-glossary)
8. [Troubleshooting](#8-troubleshooting)
9. [Summary](#summary)

---

## 1. Project Structure

Your project folder looks like this after setup:

```text
multisig/
├── contracts/
│   └── MultiSigWallet.sol   ← The smart contract
├── scripts/
│   └── deploy.js            ← Deploys the contract to Ganache
├── frontend/
│   └── index.html           ← The browser interface
├── hardhat.config.js        ← Tells Hardhat to use Ganache
└── package.json             ← Node.js project config
```

| Item                | Explanation                                                                      |
|---------------------|----------------------------------------------------------------------------------|
| `contracts/`        | Where Solidity (`.sol`) files live. Hardhat compiles them automatically.         |
| `scripts/`          | JavaScript files that Hardhat runs. `deploy.js` sends the contract to Ganache.   |
| `frontend/`         | The HTML page you open in your browser to interact with the wallet.              |
| `hardhat.config.js` | Configuration: tells Hardhat which Solidity version to use and where Ganache is. |
| `package.json`      | Lists the Node.js packages needed. Run `npm install` to get them.                |

---

## 2. Step-by-Step Setup Guide

### Step 1 — Install Node.js

Download and install Node.js from <https://nodejs.org> — choose the **LTS** version. This gives you the `npm` command used in all steps below.

> **What is Node.js?**
> Node.js lets you run JavaScript on your computer (not just in a browser). Hardhat is a Node.js program, so you need it installed first.

### Step 2 — Install Ganache

Download Ganache from <https://trufflesuite.com/ganache> and install it. Open it and click **Quickstart**. You will see 10 fake accounts, each with 100 ETH.

Important values to note from Ganache:

- **RPC Server:** `HTTP://127.0.0.1:7545` (shown at the top)
- **Chain ID:** `1337`
- For each of the first 3 accounts, click the key icon and copy the private key

### Step 3 — Create the Project Folder

Open your terminal (Command Prompt on Windows, Terminal on Mac) and run:

```bash
mkdir multisig
cd multisig
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat init

# When it asks, choose: "Create a JavaScript project"
# Press Enter for all other questions
```

### Step 4 — Add the Project Files

Copy the 4 files provided with this report into your project folder:

- `contracts/MultiSigWallet.sol` → into the `contracts/` folder
- `scripts/deploy.js` → into the `scripts/` folder
- `hardhat.config.js` → replace the one Hardhat created
- `frontend/index.html` → create the `frontend/` folder and put it there

### Step 5 — Compile the Contract

This converts your Solidity code into bytecode that Ganache can understand:

```bash
npm run compile

# You should see: Compiled 1 Solidity file successfully
```

### Step 6 — Deploy to Ganache

Make sure Ganache is open and running, then:

```bash
npm run deploy

# Output will look like:
# ✅ Contract deployed successfully!
# Contract address : 0xABC123...
# Owner 0 : 0x111...
# Owner 1 : 0x222...
# Owner 2 : 0x333...
```

**Copy these addresses** — you will need them in Step 7.

### Step 7 — Configure the Frontend

Open `frontend/index.html` in a text editor (Notepad, VS Code, etc.) and find the `CONFIG` section near the top. Fill in:

- `contractAddress`: paste the contract address from Step 6
- `owners`: paste the 3 owner addresses from Step 6
- `privateKeys`: paste the 3 private keys you copied from Ganache in Step 2

```javascript
const CONFIG = {
  contractAddress: "0xABC123...",   // from deploy output
  owners: {
    "Owner 0": "0x111...",
    "Owner 1": "0x222...",
    "Owner 2": "0x333...",
  },
  privateKeys: {
    "Owner 0": "0xPRIVATEKEY0...",  // from Ganache key icon
    "Owner 1": "0xPRIVATEKEY1...",
    "Owner 2": "0xPRIVATEKEY2...",
  },
  rpcUrl: "http://127.0.0.1:7545",
};
```

> **⚠️ Security Note**
> Pasting private keys in HTML is ONLY safe on a local test network like Ganache. Never do this with real money or on the real Ethereum network.

### Step 8 — Open the Interface

Double-click `frontend/index.html` to open it in your browser. No web server needed — it works directly as a local file.

---

## 3. How to Use the Wallet

### The Complete Workflow

The interface has a dropdown at the top that lets you switch between **Owner 0**, **Owner 1**, and **Owner 2**. This simulates having 3 different people using the wallet.

### 3.1 — Fund the Wallet

First, the wallet needs ETH in it before it can send anything:

1. Select "Owner 0" in the dropdown
2. In the "Deposit ETH" panel on the left, type an amount (e.g. `1.0`)
3. Click **Send ETH to Wallet**
4. The balance counter at the top will update

### 3.2 — Submit a Transaction

Any owner can propose a payment:

1. Select any owner in the dropdown
2. In the right panel, enter the recipient address (any Ganache account address works)
3. Enter the amount in ETH (e.g. `0.5`)
4. Leave **Data** blank (it is only for smart contract calls)
5. Click **Submit Transaction**
6. A new transaction card appears with status "Pending" and 0/2 approvals

### 3.3 — Approve the Transaction

The threshold is 2/3, so 2 owners must approve. The owner who submitted it can approve too:

1. Select "Owner 0" in the dropdown → click **✓ Approve** on the transaction card
2. Select "Owner 1" in the dropdown → click **✓ Approve** on the same card
3. The bar fills up. When it reaches 2/2, status changes to "Ready!"

### 3.4 — Execute the Transaction

Once enough approvals are collected, the Execute button appears:

1. Click **▶ Execute** on the transaction card
2. The ETH is sent to the recipient
3. The card turns grey with status "Executed"
4. The wallet balance decreases by the sent amount

### 3.5 — Revoke an Approval (Optional)

If an owner changes their mind before execution:

1. Switch to that owner in the dropdown
2. Click **✕ Revoke** on the transaction card
3. The approval is removed and the bar goes back down

---

## 4. The Solidity Contract — Explained

The contract (`MultiSigWallet.sol`) is the heart of the project. It lives on the blockchain and enforces all the rules. Here is every part explained in plain language.

### 4.1 — Events

Events are like a notification system. Every important action emits an event, which gets permanently recorded on the blockchain. The frontend listens to these events to update in real time.

```solidity
event Deposit(address indexed sender, uint amount);
event Submit(uint indexed txId);
event Approve(address indexed owner, uint indexed txId);
event Revoke(address indexed owner, uint indexed txId);
event Execute(uint indexed txId);
```

| Event     | Explanation                                                                       |
|-----------|-----------------------------------------------------------------------------------|
| `Deposit` | Fired when someone sends ETH to the wallet. Records who sent it and how much.     |
| `Submit`  | Fired when an owner proposes a new transaction. Records the transaction ID.       |
| `Approve` | Fired when an owner votes yes. Records which owner approved which transaction.    |
| `Revoke`  | Fired when an owner cancels their yes vote.                                       |
| `Execute` | Fired when a transaction is finally sent. Records which transaction was executed. |

### 4.2 — The Transaction Struct

A struct is like a custom data type — a container that groups related pieces of information together. Think of it as a row in a spreadsheet.

```solidity
struct Transaction {
    address to;      // Who receives the ETH
    uint value;      // How much ETH (in wei)
    bytes data;      // Extra data (empty for simple transfers)
    bool executed;   // Has it been sent already?
}
```

| Field           | Explanation                                                                                       |
|-----------------|---------------------------------------------------------------------------------------------------|
| `address to`    | An Ethereum address — 20 bytes, written as `0x` followed by 40 hex characters.                    |
| `uint value`    | An unsigned integer. ETH amounts are in "wei". 1 ETH = 1,000,000,000,000,000,000 wei.             |
| `bytes data`    | Raw bytes. Used when calling functions on other contracts. Leave empty (`0x`) for normal transfers. |
| `bool executed` | A boolean (true/false). Set to true once the transaction is sent, to prevent it being sent twice. |

### 4.3 — State Variables

State variables are stored permanently on the blockchain. They are the "memory" of the contract.

```solidity
address[] public owners;
mapping(address => bool) public isOwner;
uint public required;
Transaction[] public transactions;
mapping(uint => mapping(address => bool)) public approved;
```

| Variable                   | Explanation                                                                                           |
|----------------------------|-------------------------------------------------------------------------------------------------------|
| `address[] owners`         | A dynamic array of all owner addresses. You can loop over it.                                         |
| `mapping isOwner`          | A key-value map: given any address, instantly returns true or false. Faster than searching the array. |
| `uint required`            | How many approvals are needed. Set once in the constructor and never changes.                         |
| `Transaction[] transactions` | The full history. Every submitted transaction is added here permanently.                            |
| `mapping approved`         | A nested map: `approved[txId][ownerAddress] = true/false`. Tracks every vote.                         |

### 4.4 — Modifiers

A modifier is a reusable check that runs before a function. The `_;` means "now run the actual function body". Modifiers make the code cleaner — instead of repeating the same `require()` call in every function, you write it once.

```solidity
modifier onlyOwner() {
    require(isOwner[msg.sender], "Not owner");
    _;
}

modifier txExists(uint _txId) {
    require(_txId < transactions.length, "Tx does not exist");
    _;
}

modifier notApproved(uint _txId) {
    require(!approved[_txId][msg.sender], "Already approved");
    _;
}

modifier notExecuted(uint _txId) {
    require(!transactions[_txId].executed, "Already executed");
    _;
}
```

| Modifier      | Explanation                                                                                              |
|---------------|----------------------------------------------------------------------------------------------------------|
| `onlyOwner`   | `msg.sender` is the address of whoever is calling the function. This checks they are in the `isOwner` map. |
| `txExists`    | The transaction array grows from index 0. If `_txId >= length`, it does not exist.                       |
| `notApproved` | Prevents the same owner from approving twice.                                                            |
| `notExecuted` | Prevents executing an already-executed transaction (and prevents double-spending).                       |

### 4.5 — Constructor

The constructor runs exactly once, at deployment. It sets up the initial owners and the required threshold. After this, the setup is locked — you cannot add or remove owners.

```solidity
constructor(address[] memory _owners, uint _required) {
    require(_owners.length > 0, "Need at least one owner");
    require(_required > 0 && _required <= _owners.length, "Bad count");

    for (uint i = 0; i < _owners.length; i++) {
        address owner = _owners[i];
        require(owner != address(0), "Zero address");
        require(!isOwner[owner], "Duplicate owner");
        isOwner[owner] = true;
        owners.push(owner);
    }
    required = _required;
}
```

The `address(0)` check rejects the "null" address (all zeros), which is invalid. The `isOwner[owner]` check prevents the same address being added twice.

### 4.6 — The `receive()` Function

This is a special Solidity function. When someone sends ETH directly to the contract address (without calling any function), Solidity calls `receive()` automatically. Without it, the transaction would be rejected.

```solidity
receive() external payable {
    emit Deposit(msg.sender, msg.value);
}
```

The `payable` keyword is what allows ETH to be received. Without `payable`, any ETH sent to the contract is rejected.

### 4.7 — `submit()`

An owner proposes a new transaction. The transaction is added to the history array immediately, but not sent. It waits for approvals.

```solidity
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
```

The `external` keyword means this function can only be called from outside the contract (e.g. from the frontend). `calldata` is a cheap read-only memory location for function parameters.

### 4.8 — `approve()`

An owner votes YES on a pending transaction. The `approved` mapping is updated, recording that this owner approved this transaction ID.

```solidity
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
```

Note the 3 modifiers after `external`: `txExists` (transaction must exist), `notApproved` (must not have already voted), `notExecuted` (transaction must still be pending).

### 4.9 — `revoke()`

An owner withdraws their YES vote before the transaction is executed. This is the undo button for approvals.

```solidity
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
```

Notice it does **not** use the `notApproved` modifier — because to revoke, you *must* have approved first. The `require()` inside the function checks this directly.

### 4.10 — `execute()`

The most important function. It counts approvals, checks the threshold is met, then sends the ETH. Notice the order of operations:

```solidity
function execute(uint _txId)
    external
    txExists(_txId)
    notExecuted(_txId)
{
    require(_getApprovalCount(_txId) >= required, "Not enough approvals");

    Transaction storage t = transactions[_txId];
    t.executed = true;   // ← Mark FIRST, then send

    (bool success, ) = t.to.call{value: t.value}(t.data);
    require(success, "Transfer failed");

    emit Execute(_txId);
}
```

> **🔒 Security: Re-entrancy Protection**
> Setting `t.executed = true` **before** sending the ETH is critical. If we sent first, a malicious contract could call `execute()` again during the transfer (before the first call finished), draining the wallet. This technique is called **Checks-Effects-Interactions** — always update state before interacting with external contracts.

The `.call{value: ...}` is the low-level way to send ETH in Solidity. It returns a boolean `success` value which we check with `require()`.

### 4.11 — `_getApprovalCount()`

A private helper function — `private` means only the contract itself can call it, not the frontend or other contracts. It loops through all owners and counts how many approved the given transaction.

```solidity
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
```

The `view` keyword means this function only reads data — it does not modify state, so it costs no gas to call.

---

## 5. Hardhat & the Deploy Script

### 5.1 — What Hardhat Does

Hardhat replaces both Remix IDE and MetaMask for your local workflow:

| Task                | Explanation                                                                              |
|---------------------|------------------------------------------------------------------------------------------|
| Compiles `.sol` files | Turns your Solidity code into bytecode the EVM (Ethereum Virtual Machine) can run.     |
| Runs scripts        | `deploy.js` is a JavaScript file that Hardhat executes with access to the blockchain.    |
| Manages accounts    | Hardhat reads accounts from Ganache automatically when you point it to the RPC URL.      |
| Signs transactions  | Hardhat signs transactions using the private keys from Ganache — no wallet popup needed. |

### 5.2 — `hardhat.config.js` Explained

```javascript
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.13",               // Solidity compiler version
  networks: {
    ganache: {
      url: "http://127.0.0.1:7545", // Ganache RPC address
      chainId: 1337,                // Ganache chain ID
    },
  },
};
```

The network named `ganache` here matches the `--network ganache` flag in the deploy command.

### 5.3 — `deploy.js` Explained

The deploy script does 4 things in order:

1. Gets the list of accounts from Ganache (`ethers.getSigners()`)
2. Chooses the first 3 as owners
3. Compiles and deploys the contract (`getContractFactory` + `deploy`)
4. Prints the contract address and owner addresses

```javascript
const accounts = await ethers.getSigners();
// getSigners() returns all Ganache accounts as "signer" objects
// A signer = an account that can sign transactions

const owners = [
  accounts[0].address,  // .address gives the 0x... address
  accounts[1].address,
  accounts[2].address,
];

const MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");
// ContractFactory = a blueprint ready to deploy

const wallet = await MultiSigWallet.deploy(owners, required);
// This sends the deployment transaction to Ganache

await wallet.waitForDeployment();
// Wait until Ganache confirms the deployment
```

---

## 6. The Frontend — index.html

### 6.1 — How it Connects Without MetaMask

MetaMask is a browser extension that manages private keys and signs transactions. We replace it by putting the private keys directly in the `CONFIG` section and using ethers.js to sign transactions manually.

```javascript
// Normal MetaMask approach (NOT used here):
// provider = new ethers.providers.Web3Provider(window.ethereum)

// Our approach — connect directly to Ganache:
provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:7545");

// Create a signer from a private key:
currentWallet = new ethers.Wallet(privateKey, provider);

// Attach the contract to this signer:
contract = new ethers.Contract(contractAddress, ABI, currentWallet);
```

### 6.2 — The ABI

ABI stands for **Application Binary Interface**. It tells ethers.js what functions exist in the contract and what parameters they take. It is how the JavaScript frontend "speaks" to the Solidity contract.

```javascript
const ABI = [
  // Read-only (free, no gas)
  "function owners(uint) view returns (address)",
  "function required() view returns (uint)",
  "function transactions(uint) view returns (...)",
  "function approved(uint, address) view returns (bool)",

  // Write (costs gas, sends a transaction)
  "function submit(address, uint, bytes) external",
  "function approve(uint) external",
  "function revoke(uint) external",
  "function execute(uint) external",
];
```

The read-only functions (marked `view`) are free — they just read from the blockchain. The write functions send a transaction, which costs a tiny amount of fake ETH (gas) on Ganache.

### 6.3 — Switching Owners

The dropdown at the top of the interface lets you switch between owners. Under the hood, it creates a new `ethers.Wallet` with the selected private key:

```javascript
async function switchOwner(label) {
  const privateKey = CONFIG.privateKeys[label];
  currentWallet = new ethers.Wallet(privateKey, provider);
  contract = new ethers.Contract(contractAddress, ABI, currentWallet);
  // Now all contract calls are signed by this owner
}
```

### 6.4 — Reading Data from the Contract

Solidity `public` arrays and mappings automatically get getter functions. The frontend calls these to read the current state:

```javascript
// Read owners by index (0, 1, 2...) until it throws an error
for (let i = 0; ; i++) {
  try { owners.push(await contract.owners(i)); }
  catch { break; }  // throws when index is out of bounds
}

// Read a transaction by ID
const [to, value, data, executed] = await contract.transactions(i);

// Check if an owner approved a transaction
const hasApproved = await contract.approved(txId, ownerAddress);
```

### 6.5 — Sending Transactions

Write functions work the same way — ethers.js calls the function, waits for it to be mined, and then refreshes the UI:

```javascript
// Approve a transaction
const tx = await contract.approve(txId);
await tx.wait();  // Wait for Ganache to mine it
// Now refresh the UI
```

---

## 7. Key Concepts Glossary

| Term             | Explanation                                                                                                                |
|------------------|----------------------------------------------------------------------------------------------------------------------------|
| **Smart contract** | A program stored on the blockchain. It runs automatically when called and cannot be modified after deployment.         |
| **Solidity**     | The programming language used to write Ethereum smart contracts. Extension: `.sol`                                         |
| **Wei**          | The smallest unit of ETH. 1 ETH = 10^18 wei. All ETH values in Solidity are in wei.                                        |
| **Gas**          | A fee paid in ETH for every computation on the blockchain. Ganache gives fake ETH so gas is free in testing.               |
| **ABI**          | Application Binary Interface. The "menu" of functions a contract exposes, so JavaScript can call them.                     |
| **Signer**       | An account that can sign transactions. In ethers.js, created from a private key with `ethers.Wallet(key, provider)`.       |
| **Provider**     | The connection to the blockchain. For Ganache: `new ethers.providers.JsonRpcProvider(rpcUrl)`.                             |
| **mapping**      | A Solidity key-value store. Like a dictionary or hashmap. `mapping(address => bool)` maps addresses to true/false.         |
| **modifier**     | A reusable condition check in Solidity that runs before a function body.                                                   |
| **emit**         | Keyword to fire an event. Events are stored in transaction logs and the frontend can listen for them.                      |
| **require()**    | Reverts (cancels) the transaction if the condition is false. Like `assert()` but for user-facing errors.                   |
| **msg.sender**   | A global Solidity variable containing the address of whoever is calling the current function.                              |
| **msg.value**    | A global Solidity variable containing the amount of ETH (in wei) sent with the current call.                               |
| **view**         | Function modifier meaning "read-only". Does not change state, costs no gas.                                                |
| **external**     | Function can be called from outside the contract. More efficient than `public` for external calls.                         |
| **payable**      | Allows a function (or address) to receive ETH. Without it, ETH transfers are rejected.                                     |
| **storage**      | Reference to a variable stored permanently on the blockchain. Changes to it are persisted.                                 |
| **call{value}**  | Low-level way to send ETH in Solidity. Returns `(bool success, bytes data)`.                                               |
| **Re-entrancy**  | Attack where a malicious contract calls back into your contract mid-execution. Prevented by updating state before sending. |
| **RPC URL**      | Remote Procedure Call URL. The address Hardhat/ethers.js uses to talk to Ganache: `http://127.0.0.1:7545`                  |
| **Chain ID**     | A number identifying which network you are on. Ganache default: 1337. Ethereum mainnet: 1.                                 |

---

## 8. Troubleshooting

| Problem                         | Solution                                                                                                                |
|---------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| "Cannot connect to Ganache"     | Make sure Ganache is open and running before running `npm run deploy`.                                                  |
| "Compiled 0 files"              | Hardhat found no changes. Your `.sol` file may be in the wrong folder. Check the `contracts/` directory.                |
| "Invalid nonce"                 | Restart Ganache (Workspace → Restart). This resets the transaction counter.                                             |
| "Not enough approvals"          | You need at least 2 different owners to approve before executing. Switch owners in the dropdown.                        |
| "Transfer failed"               | The wallet has no ETH. Deposit some ETH first using the Deposit panel.                                                  |
| Config warning still showing    | You did not fill in all values in the `CONFIG` section of `index.html`. Check for any "PASTE" placeholders.             |
| "Not owner"                     | You are trying to approve/submit as an address that is not an owner. Check your private keys match the owner addresses. |
| Balance shows 0 after deposit   | Click ↻ Refresh. The UI does not always auto-update after a deposit.                                                    |

---

## Summary

This project implements a complete multi-signature wallet from scratch with no external wallet tool or browser extension. The full stack is:

- **Solidity contract** enforcing all rules on-chain (4 functions, 2 state maps, 1 struct)
- **Hardhat** compiling and deploying the contract to a local Ganache blockchain
- **A plain HTML frontend** connecting directly to Ganache via ethers.js
- **Private key switching** to simulate multiple owners — perfect for local testing

The key insight of the project is that MetaMask and Remix are just **tools for convenience** — they are not required. Hardhat replaces Remix for compiling and deploying. Direct private key signing with ethers.js replaces MetaMask for transaction signing.

> **Next steps to explore**
> Once comfortable with this project, you could explore: adding an owner management function (`addOwner`/`removeOwner`), writing unit tests with Hardhat, deploying to a public testnet like Sepolia, or adding a transaction expiry mechanism.
