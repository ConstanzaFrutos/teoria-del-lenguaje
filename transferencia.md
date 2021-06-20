```
truffle(ganache)> cartaItem = await CartaItem.deployed()
undefined
truffle(ganache)> cartaItem.awardItem('0x3B3BA27f29F20B5D5B43d9dF35fDf74A452208c3')
{ tx:
   '0x30f4b72c1a8df8b46c45a89602fabaf5071092df4c8ec904613e10df59bf42e6',
  receipt:
   { transactionHash:
      '0x30f4b72c1a8df8b46c45a89602fabaf5071092df4c8ec904613e10df59bf42e6',
     transactionIndex: 0,
     blockHash:
      '0x92dd1a115994f10a52425ad1f3cb9531781dd8ed8d1e54a9f398ecc4f5dc77f2',
     blockNumber: 143,
     from: '0x3b3ba27f29f20b5d5b43d9df35fdf74a452208c3',
     to: '0x5950fd778cbcb8d78de15cc073399ed03c4e5219',
     gasUsed: 207708,
     cumulativeGasUsed: 207708,
     contractAddress: null,
     logs: [ [Object], [Object] ],
     status: true,
     logsBloom:
      '0x00000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000080000000000000000020000000000000002000800000000000000000020000010000000000000000000000000000000000000000000000000000000002000000100000000000000000000000000000010000000000000000020000000000000000000000000000002000000000000000000000000000000000000000000000000000020000000000000000000000000000000400000000000000000000000000000000000',
     rawLogs: [ [Object], [Object] ] },
  logs:
   [ { logIndex: 0,
       transactionIndex: 0,
       transactionHash:
        '0x30f4b72c1a8df8b46c45a89602fabaf5071092df4c8ec904613e10df59bf42e6',
       blockHash:
        '0x92dd1a115994f10a52425ad1f3cb9531781dd8ed8d1e54a9f398ecc4f5dc77f2',
       blockNumber: 143,
       address: '0x5950Fd778cBCB8d78de15Cc073399ED03C4E5219',
       type: 'mined',
       id: 'log_fc9c6d9f',
       event: 'NuevaCarta',
       args: [Result] },
     { logIndex: 1,
       transactionIndex: 0,
       transactionHash:
        '0x30f4b72c1a8df8b46c45a89602fabaf5071092df4c8ec904613e10df59bf42e6',
       blockHash:
        '0x92dd1a115994f10a52425ad1f3cb9531781dd8ed8d1e54a9f398ecc4f5dc77f2',
       blockNumber: 143,
       address: '0x5950Fd778cBCB8d78de15Cc073399ED03C4E5219',
       type: 'mined',
       id: 'log_11b8a180',
       event: 'Transfer',
       args: [Result] } ] }
truffle(ganache)> cartaItem.transferItem('0x688e516F83C7B2B4bd797631944a95Ec93BCfe0c', 0)
{ tx:
   '0x47e1034aad5bf9627fe3e3f7a8b4acc0139195d3c7e06f07f580e87ceb3301f2',
  receipt:
   { transactionHash:
      '0x47e1034aad5bf9627fe3e3f7a8b4acc0139195d3c7e06f07f580e87ceb3301f2',
     transactionIndex: 0,
     blockHash:
      '0xa61e98abab3c29ece2dbfb64546f4964338c18e726fd7c5f93fca131aa9e06d2',
     blockNumber: 144,
     from: '0x3b3ba27f29f20b5d5b43d9df35fdf74a452208c3',
     to: '0x5950fd778cbcb8d78de15cc073399ed03c4e5219',
     gasUsed: 82270,
     cumulativeGasUsed: 82270,
     contractAddress: null,
     logs: [ [Object], [Object] ],
     status: true,
     logsBloom:
      '0x00000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000008000000000000000000000000000000080000000000000000020000000000000002000800000000010000000000000010000000000000000000000000000000000000000000000000000000002000000000000000020000000000000000000010000000000000000020000000000000000000000000000002000000000000000000000000000000000000000000000000000020000010000000000000000000000000000000000000000000000000400200000000',
     rawLogs: [ [Object], [Object] ] },
  logs:
   [ { logIndex: 0,
       transactionIndex: 0,
       transactionHash:
        '0x47e1034aad5bf9627fe3e3f7a8b4acc0139195d3c7e06f07f580e87ceb3301f2',
       blockHash:
        '0xa61e98abab3c29ece2dbfb64546f4964338c18e726fd7c5f93fca131aa9e06d2',
       blockNumber: 144,
       address: '0x5950Fd778cBCB8d78de15Cc073399ED03C4E5219',
       type: 'mined',
       id: 'log_a9a8a382',
       event: 'Approval',
       args: [Result] },
     { logIndex: 1,
       transactionIndex: 0,
       transactionHash:
        '0x47e1034aad5bf9627fe3e3f7a8b4acc0139195d3c7e06f07f580e87ceb3301f2',
       blockHash:
        '0xa61e98abab3c29ece2dbfb64546f4964338c18e726fd7c5f93fca131aa9e06d2',
       blockNumber: 144,
       address: '0x5950Fd778cBCB8d78de15Cc073399ED03C4E5219',
       type: 'mined',
       id: 'log_3ec054c6',
       event: 'Transfer',
       args: [Result] } ] }
truffle(ganache)> cartaItem.balanceOf('0x688e516F83C7B2B4bd797631944a95Ec93BCfe0c')
<BN: 1>
truffle(ganache)> cartaItem.ownerOf(0)
'0x688e516F83C7B2B4bd797631944a95Ec93BCfe0c'

```