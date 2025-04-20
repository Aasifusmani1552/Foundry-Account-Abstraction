//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {console2} from "forge-std/console2.sol";

contract MinimalAccount is IAccount, Ownable {
    ///////////////////
    /// Errors  ///////
    ///////////////////
    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();
    error MinimalAccount__CallFailed(bytes);

    ///////////////////////////
    /// State Variables ///////
    ///////////////////////////
    IEntryPoint private immutable i_entryPoint;

    //////////////////////
    /// Modifiers  ///////
    //////////////////////
    modifier requreFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
        _;
    }

    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }

    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    receive() external payable {}

    //////////////////////////////
    /// External Functions ///////
    //////////////////////////////

    function execute(address dest, uint256 value, bytes calldata functionData) external requreFromEntryPointOrOwner {
        (bool success, bytes memory result) = dest.call{value: value}(functionData);
        if (!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        _payPrefund(missingAccountFunds);
    }

    //////////////////////////////
    /// Internal Functions ///////
    //////////////////////////////

    //Uses EIP-191 format of signatures which is the basic not proper format type, so we convert userOpHash to EIP-191's structure
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash); // convert to EIP-191 structure
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        } else {
            return SIG_VALIDATION_SUCCESS;
        }
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            (success);
        }
    }

    ///////////////////
    /// Getters ///////
    ///////////////////

    function getEntryPoint() external view returns (IEntryPoint) {
        return i_entryPoint;
    }
}
