// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.6.0;


interface ICoreVault {
    function addPendingRewards(uint _amount) external;
}