#  Multi-Signature Wallet Smart Contract

A secure Multi-Signature (Multi-Sig) Smart Contract implementation built with **Solidity** and tested using **Hardhat**. This project allows multiple owners to authorize and execute Ethereum transactions collectively, requiring a predefined threshold of approvals before execution.

---

## Features

* **Multi-Owner Management**: Define multiple wallet addresses as contract owners during deployment.
* **Configurable Threshold**: Require $N$ out of $M$ approvals to confirm and execute transactions.
* **Transaction Lifecycle**: Submit, approve, revoke approval, and execute transaction workflows.
* **Web Interface**: Lightweight web dashboard (`index.html`) to interact with deployed smart contracts via Web3 providers.

---

## Tech Stack

* **Smart Contracts**: Solidity
* **Development Framework**: Hardhat
* **Testing & Scripts**: JavaScript / Ethers.js
* **Frontend**: HTML / JavaScript

---

## Getting Started

### 1. Installation

Clone the repository and install the dependencies:

```bash
git clone [https://github.com/HajarEnnajdy/multisig-smart-contract.git](https://github.com/HajarEnnajdy/multisig-smart-contract.git)
cd multisig-smart-contract
npm install
