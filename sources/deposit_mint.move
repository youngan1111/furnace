module qve_protocol::deposit_mint {
    use std::signer;
    use std::string::utf8;
    use std::vector;
    
    use qve_protocol::coins::{QVE, MQVE, AQVE, USDC, USDT};

    use pyth::pyth;
    use pyth::price::Price;
    use pyth::price_identifier;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;

    // public fun deposit_to_market_account<CoinType>(
    //     owner: &signer,
    //     accountKey: MarketAccountKey,
    //     coinIAmt: u64, // Fixedpoint value.
    //     coinQAmt: u64, // Fixedpoint value.
    // ) acquires FerumInfo, Orderbook {
    //     let marketAddr = get_market_addr<I, Q>();
    //     let book = borrow_global_mut<Orderbook<I, Q>>(marketAddr);
    //     assert!(table::contains(&book.marketAccounts, accountKey), ERR_NO_MARKET_ACCOUNT);
    //     let marketAcc = table::borrow_mut(&mut book.marketAccounts, accountKey);
    //     assert!(owns_account(owner, &accountKey, marketAcc), ERR_NOT_OWNER);
    //     if (coinIAmt > 0) {
    //         let coinIDecimals = coin::decimals<I>();
    //         let coinAmt = coin::withdraw<I>(owner, fp_convert(coinIAmt, coinIDecimals, 1 /* FP_NO_PRECISION_LOSS */));
    //         coin::merge(&mut marketAcc.instrumentBalance, coinAmt);
    //     };
    //     if (coinQAmt > 0) {
    //         let coinQDecimals = coin::decimals<Q>();
    //         let coinAmt = coin::withdraw<Q>(owner, fp_convert(coinQAmt, coinQDecimals, 1 /* FP_NO_PRECISION_LOSS */));
    //         coin::merge(&mut marketAcc.quoteBalance, coinAmt);
    //     };
    // }

    // const APTOS_USD_PRICE_FEED_IDENTIFIER : vector<u8> = x"44a93dddd8effa54ea51076c4e851b6cbbfd938e82eb90197de38fe8876bb66e";

    // public entry fun deposit_to_mm_account_entry<CoinType>(
    //     from: &signer,
    //     amount: u64,
    // ) {
    //     if (amount > 0) {
    //         let coins = coin::withdraw<CoinType>(from, amount);
    //         coin::deposit<CoinType>(@qve_protocol, coins);
    //     };
    // }

    public entry fun get_btc_usd_price(user: &signer, pyth_update_data: vector<vector<u8>>) {
        // First update the Pyth price feeds
        let coins = coin::withdraw(user, pyth::get_update_fee(&pyth_update_data));
        pyth::update_price_feeds(pyth_update_data, coins);

        // Price Feed Identifier of APT/USD in Testnet
        let btc_price_identifier = x"44a93dddd8effa54ea51076c4e851b6cbbfd938e82eb90197de38fe8876bb66e";

        // Now we can use the prices which we have just updated
        let btc_usd_price_id = price_identifier::from_byte_vec(btc_price_identifier);
        pyth::get_price(btc_usd_price_id)
    }

    // fun update_and_fetch_price(receiver : &signer,  vaas : vector<vector<u8>>) : Price {
    //     let coins = coin::withdraw<aptos_coin::AptosCoin>(receiver, pyth::get_update_fee(&vaas)); // Get coins to pay for the update
    //     pyth::update_price_feeds(vaas, coins); // Update price feed with the provided vaas
    //     pyth::get_price(price_identifier::from_byte_vec(APTOS_USD_PRICE_FEED_IDENTIFIER)) // Get recent price (will fail if price is too old)
    // }

    // #[view]
    // public fun get_aptos_price(receiver : &signer): Price {
    //     let coins = coin::withdraw<aptos_coin::AptosCoin>(receiver, pyth::get_update_fee()); // Get coins to pay for the update
    //     pyth::update_price_feeds(APTOS_USD_PRICE_FEED_IDENTIFIER, coins); // Update price feed with the provided VAA

    //     // Price Feed Identifier of APT/USD in Testnet
    //     let btc_price_identifier = x"44a93dddd8effa54ea51076c4e851b6cbbfd938e82eb90197de38fe8876bb66e";

    //     // Now we can use the prices which we have just updated
    //     let btc_usd_price_id = price_identifier::from_byte_vec(btc_price_identifier);
    //     pyth::get_price(btc_usd_price_id)
    // }
}



