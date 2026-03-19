// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//1.创建一个收款函数
//2.记录投资人
//3.在锁定期内，达到目标值，生产商可以提款
//4.在锁定期内，没有达到目标值，投资人可以在锁定期结束后提款
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
contract FundMe{

    mapping(address=>uint256) public fundersToAmount;
    uint256 MIMIMUM_VALUE = 100*10**18;//usd，经过Feed处理，这里比较的时候，应该是美元的价格比较
    //其次，price的价格是 2000u/eth,但是fund的时候是以wei为单位，比如fund 0.1eth，实际ethAmount的值是0.1*10**18,
    //所以，convert函数中实际做运算的单位是0.1eth * 2000u/eth*精度 * 10^18 / 精度，所以最终返回值被放大了10^18。 
    AggregatorV3Interface internal dataFeed;

    uint256 constant TARGET = 1000 * 10 **18;
    address owner;
    uint256 deployTimeStamp;
    uint256 lockTime;
    constructor(uint256 _lockTime)
    {
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;

        //合约部署时会自动调用构造函数，此时设置开始时间戳
        deployTimeStamp = block.timestamp;
        lockTime = _lockTime;
    }
    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MIMIMUM_VALUE,"send more ETH");
        require(block.timestamp < deployTimeStamp+lockTime,"window is cloesd");
        fundersToAmount[msg.sender] += msg.value;
    }
   /**
   * Returns the latest answer.
   */
  function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
    // prettier-ignore
    (
      /* uint80 roundId */
      ,
      int256 answer,
      /*uint256 startedAt*/
      ,
      /*uint256 updatedAt*/
      ,
      /*uint80 answeredInRound*/
    ) = dataFeed.latestRoundData();
    return answer;
  }
    function convertEthToUsd(uint256 ethAmount) internal view returns(uint256){
        uint256 ethprice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount*ethprice/(10**8);
        //因为是eht兑美元，假设ethprice的单位是 0.1u/wei，但是有精度，所以实际ethprice的值是0.1*10^8 / wei
        //10^8是所有货币兑美元的精度，是一个固定值，不是计算来的
        //那么我们需要知道的是ethAmount比如2000wei是多少u，就是2000 * 0.1 * 10^8，显然，要除以精度才是正确的u值
    }
    //收款操作
    function getFund() external windowClosed onlyOwn {
      require(convertEthToUsd(address(this).balance) >= TARGET,"TARGET is not reached!");
      
      //转钱
      //1.transfer
      //payable(msg.sender).transfer(address(this).balance);
      //2.send
      //bool success = payable(msg.sender).send(address(this).balance);
      //3.call（推荐使用）
      bool success;
      (success,) = payable(msg.sender).call{value:address(this).balance}("");
      require(success,"tx is failed");
      fundersToAmount[msg.sender] = 0;
    }

    //退款操作
    function reFund() external windowClosed {
      require(convertEthToUsd(address(this).balance) < TARGET,"TARGET is reached!");
      require(fundersToAmount[msg.sender] != 0,"you are not a funder!");
     
      bool success;
      (success,) = payable(msg.sender).call{value:fundersToAmount[msg.sender]}("");
      require(success,"tx is failed");
      fundersToAmount[msg.sender] = 0;
    }
    //转移所有者
    function transferOwnership(address newOwner) public onlyOwn {
      
      owner = newOwner;
    }

    modifier windowClosed(){
       require(block.timestamp >= deployTimeStamp + lockTime,"window is not closed!");
       _;
    }
    modifier onlyOwn(){
        require(msg.sender == owner,"the function can only be called by owner!");
        _;
    }
}