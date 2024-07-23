### 先初始化环境
```
./init_ubuntu.sh
```

### 再生成 proof
```
./script/generate-proof.sh
```


----
### 目录介绍
#### circuits
放置各种测试电路的源码

#### emls
放置满足各种测试电路的测试原始数据

#### test
放置解析各种测试电路input.json的 ts 工具，使用 emls 中对应的原始数据

#### scripts
放置 shell 脚本，便于执行 snarkjs 命令

#### target
放置各种测试电路的编译结果和输出结果


## 问题
#### yarn 报错
```
yarn install v1.22.22
info No lockfile found.
[1/4] Resolving packages...
error Error: certificate has expired
    at TLSSocket.onConnectSecure (node:_tls_wrap:1674:34)
    at TLSSocket.emit (node:events:519:28)
    at TLSSocket._finishInit (node:_tls_wrap:1085:8)
    at ssl.onhandshakedone (node:_tls_wrap:871:12)
```
禁用SSL检查即可，因为是临时测试demo，无需严格SSL
`yarn config set strict-ssl false`


#### 内存不足
```
snarkjs g16s demo-zk-email-six-big.r1cs ../../powersOfTau28_hez_final_24.ptau demo-zk-email-six-big_0000.zkey
[INFO]  snarkJS: Reading r1cs
[INFO]  snarkJS: Reading tauG1
[INFO]  snarkJS: Reading tauG2
[INFO]  snarkJS: Reading alphatauG1
[INFO]  snarkJS: Reading betatauG1
terminate called after throwing an instance of 'std::bad_alloc'
  what():  std::bad_alloc
Aborted (core dumped)
```
先限制 node 进程使用的内存大小 `NODE_OPTIONS=--max_old_space_size=32768`
再设置系统内核参数，调整进程能创建的内存映射区域数量，将默认值放大10倍吧 `sysctl -w vm.max_map_count=655300 && sysctl -p`
引用：https://hackmd.io/V-7Aal05Tiy-ozmzTGBYPA?view
