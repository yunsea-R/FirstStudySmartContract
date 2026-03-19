// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken{
    //1.Token的名称
    string public TokenName;
    //2.Token的简称
    string public TokenSymbol;
    //3.Token的数量
    uint256 public TokenAmount;
    //4.owner的地址
    address public owner;
    //余额和地址的映射表
    mapping(address => uint256) public  balances;

}