pragma solidity ^0.5.0;
contract B4B {

    uint deployDate;

    constructor() public {
    deployDate = now;
    }


    struct Campaign {
        address  brand_addr; // brand address to book campaign
        address  influencer_addr;

        uint date; //TODO more booked dates, struct of ads and mapping with influencer
        bool book_status; // 0 - date free to book; 1 - date is booked
        bool accept_status; // 0 - ads is not accepted by influencer; 1 - ads is accepted by influencer
        bool complete_status; // 0 - ads is not completed by influencer; 1 - ads is completed by influencer
        bool approved_status; // 0 - ads is not approved by brand; 1 - ads is approved by brand
        uint256 paid; //how much paid by brand
    }
    
    uint numCampaigns;

    mapping (uint => Campaign) campaigns;

    struct Influencer {
        address influencer_addr; //TODO maybe it is including in mapping
        uint256 price; //TODO 3 types of prices
        uint256 points;
        uint256 coins; //TODO Coins = ERC20 Token
        uint lastDistributionDate;
    }

    mapping(address => Influencer) influencers;

    function ChangePrice (uint256 _price) public {
        Influencer storage i = influencers[msg.sender];
        i.influencer_addr = msg.sender;
        i.price = _price;
    }

    function NewBooking (address  _influencer) public payable returns (uint campaignID) {
        Influencer storage i = influencers[_influencer];
        require (i.price == msg.value);

        campaignID=numCampaigns++;
        Campaign storage c = campaigns[campaignID];
        c.brand_addr = msg.sender;
        c.influencer_addr = _influencer;
        c.date = now;
        c.book_status = true;
        c.accept_status = false;
        c.complete_status = false;
        c.approved_status = false;
        c.paid = i.price;
    }

    function AcceptBooking (uint _campaignID) public {
        Campaign storage c = campaigns[_campaignID];
        require (c.influencer_addr==msg.sender);
        require (c.book_status==true);
        require (c.accept_status==false);
        c.accept_status=true; // TODO: more status type - for reject

        Influencer storage i = influencers[msg.sender];
        i.points+=10; //TODO - faster I book, more points receive
        
    }

    function CompleteAds (uint _campaignID) public {
        Campaign storage c = campaigns[_campaignID];
        require (c.influencer_addr==msg.sender);
        require (c.book_status==true);
        require (c.accept_status==true);
        require (c.complete_status==false);
        c.complete_status=true; // TODO: more status type - for reject
        
        Influencer storage i = influencers[msg.sender];
        i.points+=10; //TODO - faster I book, more points receive

    }

    function ApproveAds (uint _campaignID) public {
        Campaign storage c = campaigns[_campaignID];
        require (c.brand_addr==msg.sender);
        require (c.book_status==true);
        require (c.accept_status==true);
        require (c.complete_status==true);
        require (c.approved_status==false);
        c.approved_status=true;
    }

    function ReceiveSalary (uint _campaignID) public {
        Campaign storage c = campaigns[_campaignID];
        require (c.influencer_addr==msg.sender);
        require (c.book_status==true);
        require (c.accept_status==true);
        require (c.complete_status==true);
        require (c.approved_status==true);
        
        uint256 _d = c.paid;
        msg.sender.transfer(_d);
        c.paid=0;
    }

    function BookStatus(uint _campaignID) public view returns (bool) {
        Campaign storage c = campaigns[_campaignID];
        return c.book_status;
    }
    
    function AcceptStatus(uint _campaignID) public view returns (bool) {
        Campaign storage c = campaigns[_campaignID];
        return c.accept_status;
    }
    
    function CompleteStatus(uint _campaignID) public view returns (bool) {
        Campaign storage c = campaigns[_campaignID];
        return c.complete_status;
    }
    
    function ApprovedStatus(uint _campaignID) public view returns (bool) {
        Campaign storage c = campaigns[_campaignID];
        return c.approved_status;
    }

    function PaidOnContract (uint _campaignID) public view returns (uint256) {
        Campaign storage c = campaigns[_campaignID];
        return c.paid;
    }

    function PointsBalance (address _influencer) public view returns (uint256) {
        Influencer storage i = influencers[_influencer];
        return i.points;
    }

    function TakeCoins () public returns (uint256) {
        require (now-deployDate>30 days);
        
        Influencer storage i = influencers[msg.sender];
        require (now-i.lastDistributionDate>30 days);

        i.coins = i.points*100;

        i.lastDistributionDate+= 30 days;
        
        return i.coins;
    }
}