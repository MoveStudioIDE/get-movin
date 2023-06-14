// This is an example module that creates a new cryptocurrency called MYCOIN. It uses the Sui coin 
// standard to do so. This module code was inspired by the Sui Move by Example book 
// (https://examples.sui.io/samples/coin.html)
// 
// coin module: https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#module-0x2coin
module examples::mycoin {
    
    use std::option;
    use sui::coin;                          // https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md
    use sui::transfer;                      // https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/transfer.md
    use sui::url::{Self, Url};              // https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/url.md
    use sui::tx_context::{Self, TxContext}; // https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/tx_context.md

    /// The type identifier of coin. The coin will have a type tag of kind: 
    /// `Coin<package_object::mycoin::MYCOIN>`
    /// Make sure that the name of the type matches the module's name.
    struct MYCOIN has drop {}

    /// Module initializer is called once on module publish. A treasury cap is sent to the 
    /// publisher, who then controls minting and burning
    //
    // coin::create_currency(): https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#function-create_currency
    // transfer::public_freeze_object(): https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/transfer.md#function-public_freeze_object
    // transfer::public_transfer(): https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/transfer.md#function-public_transfer
    fun init
    (
        witness: MYCOIN, 
        ctx: &mut TxContext
    ) 
    {
        // Function interface: public fun create_currency<T: drop>(witness: T, decimals: u8, symbol: vector<u8>, name: vector<u8>, description: vector<u8>, icon_url: option::Option<url::Url>, ctx: &mut tx_context::TxContext): (coin::TreasuryCap<T>, coin::CoinMetadata<T>)
        let (treasury, metadata) = coin::create_currency(
            /*witnes=*/witness, 
            /*decimals=*/6, 
            /*symbol=*/b"MYCOIN", 
            /*name=*/b"Example coin", 
            /*description=*/b"This is a coin that I created along my journey to learn Sui Move!", 
            /*icon_url=*/option::some<Url>(url::new_unsafe_from_bytes(b"https://d3hnfqimznafg0.cloudfront.net/image-handler/ts/20200218065624/ri/950/src/images/Article_Images/ImageForArticle_227_15820269818147731.png")), 
            /*ctx=*/ctx
        );
        
        // Freezes the object. Freezing the object means that the object: 
        // - Is immutable
        // - Cannot be transferred
        //
        // Note: transfer::freeze_object() cannot be used since CoinMetadata is defined in another 
        //       module
        transfer::public_freeze_object(metadata);
        
        // Send the TreasuryCap object to the publisher of the module
        //
        // Note: transfer::transfer() cannot be used since TreasuryCap is defined in another module
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    // This function is an example of how internal_mint_coin() can be used. 
    // 
    // Note that there is coin::mint_and_transfer but this examples shows how 
    // transfer::public_transfer works
    // 
    // coin::mint_and_transfer(): https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#function-mint_and_transfer
    // transfer::public_transfer(): https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/transfer.md#function-public_transfer
    public entry fun mint
    (
        cap: &mut coin::TreasuryCap<examples::mycoin::MYCOIN>, 
        recipient: address,
        value: u64, 
        ctx: &mut tx_context::TxContext
    )
    {
        // mint the new coin with the given value
        let new_coin = internal_mint_coin(cap, value, ctx);

        // transfer the new coin to the recipient
        transfer::public_transfer(new_coin, recipient)
    }

    // This function is an example of how internal_burn_coin() can be used.
    public entry fun burn
    (
        cap: &mut coin::TreasuryCap<examples::mycoin::MYCOIN>, 
        coin: coin::Coin<examples::mycoin::MYCOIN>
    )
    {
        // Burn the coin 
        // 
        // Note: internal_burn_coin returns a u64 but it can be ignored since u64 has drop
        internal_burn_coin(cap, coin);
    }
    
    // This is the internal mint function. This function uses the Coin::mint function to create and 
    // return a new Coin object containing a balance of the given value
    //
    // coin::mint(): https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#function-mint
    fun internal_mint_coin
    (
        cap: &mut coin::TreasuryCap<examples::mycoin::MYCOIN>, 
        value: u64, 
        ctx: &mut tx_context::TxContext
    ): coin::Coin<examples::mycoin::MYCOIN>
    { 
        coin::mint(cap, value, ctx)
    } 

    // This is the internal burn function. This function uses the Coin::burn function to take a coin
    // and destroy it. The function returns the value of the coin that was destroyed.
    //
    // coin::burn(): https://github.com/MystenLabs/sui/blob/main/crates/sui-framework/docs/coin.md#function-burn
    fun internal_burn_coin
    (
        cap: &mut coin::TreasuryCap<examples::mycoin::MYCOIN>, 
        coin: coin::Coin<examples::mycoin::MYCOIN>
    ): u64
    {
        coin::burn(cap, coin)
    }
}