export set MODULE=0x77743d6b1f4222f7768914c915304e5a3c4ac55851cb7d5d8dc0f1fdd7d0bbf9
export set USER=0xb44a3ed8bff3901819a49dd22ebfa760e75561ba3b4e636639d1f74ffad7dea3
export set PETRA=0xf763fe2af78283f67909c9424ecbda781e106011777e7b92561972f33edf0c3a

# module 함수 실행
aptos move run \
  --function-id $MODULE::message::set_message \
  --args 'string:this is test plz plz plz plz'



# coin 만들기
# 0. (한번만 실행하면됨) module owner 계정으로 fake coin 만들기
aptos move run \
  --function-id $MODULE::usdf::create_usdf \
  --profile testnet4
# 1. register the tokens with our account so we can receive it
aptos move run \
  --type-args $MODULE::usdf::USDF \
  --function-id 0x1::managed_coin::register \
  --profile testnet4
# 2. 다른 아무 계정으로 fake coin minting 하기
aptos move run \
  --function-id $MODULE::usdf::mint_usdf \
  --args u64:100000000000000 \
  --profile testnet
  
# QVE minting
# 0. (한번만 실행하면됨) module owner 계정으로 fake coin 만들기
aptos move run \
  --function-id $MODULE::qve::create_qve \
  --profile testnet4
# 1. register the tokens with our account so we can receive it
aptos move run \
  --type-args $MODULE::qve::QVE \
  --function-id 0x1::managed_coin::register \
  --profile testnet4
# 2. 다른 아무 계정으로 fake coin minting 하기
aptos move run \
  --function-id $MODULE::qve::mint_qve \
  --args u64:100000000000000 \
  --profile testnet

# mQVE minting
# 0. (한번만 실행하면됨) module owner 계정으로 fake coin 만들기
aptos move run \
  --function-id $MODULE::qve::create_qve \
  --profile testnet4
# 1. register the tokens with our account so we can receive it
aptos move run \
  --function-id 0x1::managed_coin::register \
  --type-args $MODULE::qve::QVE \
  --profile testnet4
# 2. 다른 아무 계정으로 fake coin minting 하기
aptos move run \
  --function-id $MODULE::qve::mint_qve \
  --args u64:100000000000000 \
  --profile testnet

# 코인 한번에 register
aptos move run \
  --function-id $MODULE::universal_coin::register_coins \
  --profile testnet5
# 코인 개별 유저 지갑에 등록 QVE, mQVE, aQVE, USDC, USDT
aptos move run \
  --function-id 0x1::managed_coin::register \
  --type-args $MODULE::universal_coin::QVE \
  --profile testnet2
# 코인 mint 모듈 owner만 가능하다
aptos move run \
  --function-id $MODULE::universal_coin::mint_coin \
  --type-args $MODULE::universal_coin::QVE \
  --args address:0x3eac2782851d36044593da16801fe9ebef49a31e7d4ee35c1d6a238cc52596bd u64:100000000 \
  --profile testnet5



# 계좌 resources 확인 100000000 -> '0' 8개가 하나다
curl --request GET \
  --url http://0.0.0.0:8080/v1/accounts/$PETRA/resources \
  --header 'Content-Type: application/json' | jq .
# usdf 잔고 확인
curl --request GET \
  --url http://0.0.0.0:8080/v1/accounts/$USER/resource/0x1::coin::CoinStore%3C0x$MODULE::usdf::USDF%3E \
  --header 'Content-Type: application/json' | jq .
# transfer coin to somewhere else
aptos move run \
  --function-id $MODULE::basic_coin::coin_transfer \
  --type-args $MODULE::usdf::USDF \
  --args address:0xb44a3ed8bff3901819a49dd22ebfa760e75561ba3b4e636639d1f74ffad7dea3 u64:100000000 \
  --profile default
# deposit to mm account
aptos move run \
  --function-id $MODULE::basic_coin::deposit_to_mm_account_entry \
  --type-args $MODULE::usdf::USDF \
  --args u64:100000000 \
  --profile default

# liquidswap 기존 풀을 활용한 apt -> btc | usdt swap function
aptos move run \
  --function-id $MODULE::example::test_btc \
  --profile testnet1
aptos move run \
  --function-id $MODULE::example::test_usdt \
  --profile testnet1






# pool 생성하기

# liquidswap create my qve_usdf_pool
aptos move run \
  --function-id $MODULE::qve_usdf_pool::create_pool \
  --profile testnet4
# universal stable pool 생성하기 
aptos move run \
  --function-id $MODULE::pool::create_stable_pool \
  --type-args $MODULE::universal_coin::MQVE $MODULE::universal_coin::USDC \
  --profile testnet4

# universal create pool
aptos move run \
  --function-id $MODULE::pool::create_pool \
  --type-args $MODULE::qve::QVE $MODULE::usdf::USDF \
  --profile testnet4
# add_liquidity to my pool
aptos move run \
  --function-id $MODULE::qve_usdf_pool::add_liquidity \
  --profile testnet
# swap qve -> usdf  
aptos move run \
  --function-id $MODULE::qve_usdf_pool::test_swap \
  --profile testnet
# liquidswap burn lp token
aptos move run \
  --function-id $MODULE::qve_usdf_pool::burn_liquidity \
  --args u64:1000000000 u64:100000000 u64:100000000 \
  --profile testnet
# 풀의 reserve 사이즈 구하기
curl --request POST \
  --url https://fullnode.testnet.aptoslabs.com/v1/view \
  --header 'Content-Type: application/json' \
  --data '{
  "function": "dbd4b1742ac096bc8b881a6837842692d46b932754f82f8d9ebd0b908534bee4::qve_usdf_pool::get_reserve",
  "type_arguments": [],
  "arguments": []
}' | jq .


# view function get_message
curl --request POST \
  --url http://0.0.0.0:8080/v1/view \
  --header 'Content-Type: application/json' \
  --data '{
  "function": "8fdb0bbefb74e696d61052690ab837dc0b3ba40677f58e249ef561edcbeb0f20::message::get_message",
  "type_arguments": [],
  "arguments": [
   "b44a3ed8bff3901819a49dd22ebfa760e75561ba3b4e636639d1f74ffad7dea3"
  ]
}' | jq .

# get user config
cat .aptos/config.yaml

# get local module info
curl --request GET \
  --url http://0.0.0.0:8080/v1/accounts/$MODULE/module/basic_coin \
  --header 'Content-Type: application/json' | jq .
# get testnet module info
curl --request GET \
  --url https://fullnode.testnet.aptoslabs.com/v1/accounts/$MODULE/modules \
  --header 'Content-Type: application/json' | jq .

# message module의 event 접근
curl --request GET \
  --url http://0.0.0.0:8080/v1/accounts/$USER/events/$MODULE::message::MessageHolder/message_change_events | jq .
