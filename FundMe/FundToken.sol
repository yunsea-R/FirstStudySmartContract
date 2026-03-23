// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken{
    //1.Token的名称
    string public TokenName;
    //2.Token的简称
    string public TokenSymbol;
    //3.Token的数量，总的流通量
    uint256 public TokenAmount;
    //4.owner的地址
    address public owner;
    //余额和地址的映射表
    mapping(address => uint256) public  balances;

    constructor(string memory Name,string memory Symbol){
        TokenName = Name;
        TokenSymbol = Symbol;
        owner = msg.sender;//部署合约的人
    }

    //mint:获取通证
    function mint(uint256 amountMint) public {
        balances[msg.sender] += amountMint;//得到了通证
        TokenAmount += amountMint;
    }
    //转账通证
     function transfer(address to,uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance.");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
    //查看账号的通证数量
    function balanceOf(address who) public view returns(uint256) {
        return balances[who];
    }
}