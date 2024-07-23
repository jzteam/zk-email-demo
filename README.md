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
