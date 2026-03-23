
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";
//1.捐款的人根据Mapping来获取相应的通证数量
//2.这类通证是Fungible token，所以Funders可以互相transfer
//3.使用完通证后，要burn token
contract FundTokenERC20 is ERC20 {
    FundMe fundme;
    constructor(address _fundme) ERC20("FundTokenERC20","FT"){
        fundme =FundMe(_fundme);
    }
    function mint(uint256 TokenAmount)public{
        require(fundme.fundersToAmount(msg.sender) >= TokenAmount,"You cannot mint this many tokens");
        require(fundme.getFundSuccess(),"the fundme is not complete yet");
        _mint(msg.sender, TokenAmount);
        //改变funder的值
        fundme.setFundersAmount(msg.sender, fundme.fundersToAmount(msg.sender) - TokenAmount);
    } 

    function claim(uint256 amountToClaim) public {
        //complete claim
        require(balanceOf(msg.sender) >= amountToClaim,"You do not have enough tokens to claim");  
        require(fundme.getFundSuccess(),"the fundme is not complete yet");
        //burn token
        _burn(msg.sender, amountToClaim);
    }
}