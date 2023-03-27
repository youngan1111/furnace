module hello_blockchain::universal_coin {
    use std::signer;
    use std::string::utf8;

    use aptos_framework::coin::{Self, MintCapability, BurnCapability};

    struct QVE {}
    struct MQVE {}
    struct AQVE {}
    struct USDC {}
    struct USDT {}

    /// Storing mint/burn capabilities for `MQVE` and `USDC` coins under user account.
    struct Caps<phantom CoinType> has key {
        mint: MintCapability<CoinType>,
        burn: BurnCapability<CoinType>,
    }

    /// Initializes `USDC` and `MQVE` coins.
    public entry fun register_coins(token_admin: &signer) {
        let (usdt_b, usdt_f, usdt_m) =
            coin::initialize<USDT>(token_admin,
                utf8(b"Tether"), utf8(b"USDT"), 8, true);
        let (usdc_b, usdc_f, usdc_m) =
            coin::initialize<USDC>(token_admin,
                utf8(b"USD Coin"), utf8(b"USDC"), 8, true);
        let (qve_b, qve_f, qve_m) =
            coin::initialize<QVE>(token_admin,
                utf8(b"QVE Protocol"), utf8(b"QVE"), 8, true);
        let (mqve_b, mqve_f, mqve_m) =
            coin::initialize<MQVE>(token_admin,
                utf8(b"mQVE Protocol"), utf8(b"MQVE"), 8, true);
        let (aqve_b, aqve_f, aqve_m) =
            coin::initialize<AQVE>(token_admin,
                utf8(b"aQVE Protocol"), utf8(b"AQVE"), 8, true);

        coin::destroy_freeze_cap(usdc_f);
        coin::destroy_freeze_cap(usdt_f);
        coin::destroy_freeze_cap(qve_f);
        coin::destroy_freeze_cap(mqve_f);
        coin::destroy_freeze_cap(aqve_f);

        move_to(token_admin, Caps<USDT> { mint: usdt_m, burn: usdt_b });
        move_to(token_admin, Caps<USDC> { mint: usdc_m, burn: usdc_b });
        move_to(token_admin, Caps<QVE> { mint: qve_m, burn: qve_b });
        move_to(token_admin, Caps<MQVE> { mint: mqve_m, burn: mqve_b });
        move_to(token_admin, Caps<AQVE> { mint: aqve_m, burn: aqve_b });
    }

    /// Mints new coin `CoinType` on account `acc_addr`.
    public entry fun mint_coin<CoinType>(token_admin: &signer, acc_addr: address, amount: u64) acquires Caps {
        let token_admin_addr = signer::address_of(token_admin);
        let caps = borrow_global<Caps<CoinType>>(token_admin_addr);
        let coins = coin::mint<CoinType>(amount, &caps.mint);
        coin::deposit(acc_addr, coins);
    }
}
