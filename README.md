🧠 Account Abstraction Project: Ethereum & zkSync
This project demonstrates smart contract wallets (Account Abstraction, AA) for Ethereum and zkSync, simulating the full flow of user operations. It includes deployment, configuration, and testing of minimal AA-compatible accounts on both chains.

🔁 Account Abstraction Flow
📦 Ethereum Flow (Manual AA with EntryPoint)
flowchart TD
A[EOA signs packed UserOp] --> B[Send UserOp to EntryPoint]
B --> C[EntryPoint calls validateUserOp() on MinimalAccount]
C --> D[validateSignature + nonce checks]
D --> E[If valid, EntryPoint calls execute() on MinimalAccount]
E --> F[Tx is executed]

🌀 zkSync Flow (Native AA support)
flowchart TD
A[EOA sends tx with smart wallet sender] --> B[zkSync verifies via validateTransaction()]
B --> C[zkSync calls executeTransaction()]
C --> D[Smart account logic executed]

🧱 Contracts
MinimalAccount.sol (Ethereum)
A smart contract wallet that complies with Ethereum’s AA pattern using the EntryPoint contract.

validateUserOp(...): Verifies signature and nonce.

execute(...): Executes the desired operation.

nonce, owner, and entry point logic included.

ZkMinimalAccount.sol (zkSync)
A zkSync-native account abstraction wallet. Implements required methods for zkSync’s protocol-level AA:

validateTransaction(...)

executeTransaction(...)

🛠️ Scripts
DeployMinimal.s.sol
Deploys the MinimalAccount.sol on Ethereum with configurable entry point and deployer account.

helperConfig.s.sol
A utility script that provides environment-specific configuration:

Detects chain ID (Anvil, Sepolia, etc.)

Returns EntryPoint contract address

Deploys a mock EntryPoint when running on Anvil

Manages deployer accounts for local/testnet environments

SendPackedUserOp.s.sol
Generates a signed UserOperation (packed format), and simulates the process of sending it to the EntryPoint for execution—this script mimics the entire AA lifecycle.

🧪 Tests
MinimalAccount.t.sol
Tests validation, execution, and signature handling on Ethereum

Covers mock EntryPoint interactions for complete AA simulation

ZkMinimalAccount.t.sol
Tests zkSync native AA methods (validateTransaction, executeTransaction)

No deployment script (due to lack of full forge script support on zkSync yet)

📁 Directory Structure
contracts/
│ MinimalAccount.sol
│ ZkMinimalAccount.sol
scripts/
│ DeployMinimal.s.sol
│ helperConfig.s.sol
│ SendPackedUserOp.s.sol
test/
│ MinimalAccount.t.sol
│ ZkMinimalAccount.t.sol

🌐 Compatibility
✅ Ethereum (tested with local Anvil and Sepolia)

✅ zkSync (native AA, tested via zkSync development tools)

❌ No zkSync forge script deployment yet (as zkSync doesn’t support it)

🚀 Getting Started
Install dependencies
forge install

Deploy MinimalAccount (Ethereum)
forge script script/DeployMinimal.s.sol --rpc-url $RPC_URL --broadcast --verify --account <accountAlias>

Run simulation
forge script script/SendPackedUserOp.s.sol --rpc-url $RPC_URL --account <accountAlias>

Run tests
forge test

🧠 Learn More
EIP-4337: https://eips.ethereum.org/EIPS/eip-4337

zkSync AA Docs: https://era.zksync.io/docs/

Foundry Book: https://book.getfoundry.sh/

zkSync Foundry Support: https://foundry-book.zksync.io/

🧑‍💻 Author
Made with 💙 by a dev exploring smart contract wallets on L2s.