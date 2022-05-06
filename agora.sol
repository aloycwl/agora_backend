pragma solidity>0.8.0;//SPDX-License-Identifier:None
//interface erc721 for nft
//interface erc20 + eth contract address for purchase
/*
Only getting the essentials
*/
interface IERC721{
    function ownerOf(uint256 tokenId)external view returns(address owner);
    function transferFrom(address from,address to,uint256 tokenId)external;
    function tokenURI(uint256 tokenId)external view returns(string memory);
}

contract agora{
    //list nfts function
        //to list the latest one first
    //input function
    //create allowance function
    struct List{
        address contractAddr;
        address owner;
        uint tokenId;
        uint price;
    }
    uint[]enumList;
    mapping(uint=>List)public list;
    function Sell(address _contractAddr,uint _tokenId)external{
        list
    }
    function Buy()external{

    }
    function List(uint batch){
        
    }
}