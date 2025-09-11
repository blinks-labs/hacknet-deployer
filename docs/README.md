# Hackathon Tests

### Infrastructure and Setup

Each team gets a cluster of p2pnodes:

```
us-west1-hackathon-team-02-cluster-b-1,us-west1-a,34.169.22.79
us-west1-hackathon-team-02-cluster-b-2,us-west1-a,35.230.6.152
asia-northeast1-hackathon-team-02-cluster-b-1,asia-northeast1-a,35.221.124.221
asia-northeast1-hackathon-team-02-cluster-b-2,asia-northeast1-a,34.153.201.35
us-east4-hackathon-team-02-cluster-b-1,us-east4-a,34.86.40.93
us-east4-hackathon-team-02-cluster-b-2,us-east4-a,34.48.236.140
australia-southeast1-hackathon-team-02-cluster-b-1,australia-southeast1-a,34.40.202.126
australia-southeast1-hackathon-team-02-cluster-b-2,australia-southeast1-a,35.197.188.230
europe-west2-hackathon-team-02-cluster-b-1,europe-west2-a,35.197.230.89
europe-west2-hackathon-team-02-cluster-b-2,europe-west2-a,35.242.138.80
europe-west3-hackathon-team-02-cluster-b-1,europe-west3-a,34.107.102.11
europe-west3-hackathon-team-02-cluster-b-2,europe-west3-a,35.234.72.115
```

This cluster contains:

- p2pnodes
- Proxies

And

```
name,zone,nat_ip
northamerica-northeast1-optimum-shared-vm-1,northamerica-northeast1-a,34.152.37.18
```

- Optmum shared vm 

Each cluster has a login user `optimumuser` and a cluster password which will be sending it by mail

### Experiments

#### Mump2p Experiments



#### RGPC Experiments



, here is what you run, here is the IP address
try this different proxies, see if you can publish and subscribe

what kind of data can you make out of this? can you plot it

latency from node to node, node location, message size 



```
Recv:	[250]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614175397077962, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614175023232000, 4000]	topic:mytopic	hash:04b18eb4	protocol:WebSocket
Recv:	[251]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614175649791987, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614175272775206, 4000]	topic:mytopic	hash:7f68dcb2	protocol:WebSocket
Recv:	[252]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614175926938734, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614175534578374, 4000]	topic:mytopic	hash:64686731	protocol:WebSocket
Recv:	[253]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614176179087469, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614175812810976, 4000]	topic:mytopic	hash:7d000af8	protocol:WebSocket
Recv:	[254]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614176421604799, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614176065426315, 4000]	topic:mytopic	hash:26a001b5	protocol:WebSocket
Recv:	[255]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614176678065615, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614176303915022, 4000]	topic:mytopic	hash:390483e8	protocol:WebSocket
Recv:	[256]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614176945069993, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614176559525407, 4000]	topic:mytopic	hash:80b559de	protocol:WebSocket
Recv:	[257]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614177189083922, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614176822216070, 4000]	topic:mytopic	hash:9c9e4d9c	protocol:WebSocket
Recv:	[258]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614177460530104, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614177064250909, 4000]	topic:mytopic	hash:6520253d	protocol:WebSocket
Recv:	[259]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614177716521770, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614177343038527, 4000]	topic:mytopic	hash:8301aff6	protocol:WebSocket
Recv:	[260]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614177967118749, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614177599439355, 4000]	topic:mytopic	hash:630fae21	protocol:WebSocket
Recv:	[261]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614178220284647, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614177848158450, 4000]	topic:mytopic	hash:726ae3dc	protocol:WebSocket
Recv:	[262]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614178480156136, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614178105204172, 4000]	topic:mytopic	hash:a681c8d1	protocol:WebSocket
Recv:	[263]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614178723161786, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614178362109939, 4000]	topic:mytopic	hash:ff1029f4	protocol:WebSocket
Recv:	[264]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614178970539780, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614178604592174, 4000]	topic:mytopic	hash:28dc2f9f	protocol:WebSocket
Recv:	[265]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614179229380256, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614178854733683, 4000]	topic:mytopic	hash:0567f548	protocol:WebSocket
Recv:	[266]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614179508344761, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614179107962096, 4000]	topic:mytopic	hash:2c52ef02	protocol:WebSocket
Recv:	[267]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614179786547906, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614179385319754, 4000]	topic:mytopic	hash:9cc6e544	protocol:WebSocket
Recv:	[268]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614180039937382, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614179669722462, 4000]	topic:mytopic	hash:48b4940e	protocol:WebSocket
Recv:	[269]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614180308589912, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614179926296250, 4000]	topic:mytopic	hash:91d0afb0	protocol:WebSocket
Recv:	[270]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614180577637678, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614180194206076, 4000]	topic:mytopic	hash:711bee56	protocol:WebSocket
Recv:	[271]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614180845829303, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614180451438143, 4000]	topic:mytopic	hash:155fdaa2	protocol:WebSocket
Recv:	[272]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614181119350349, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614180729429307, 4000]	topic:mytopic	hash:711f25bd	protocol:WebSocket
Recv:	[273]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614181380152705, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614181003488260, 4000]	topic:mytopic	hash:6b386f24	protocol:WebSocket
Recv:	[274]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614181645811679, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614181263104459, 4000]	topic:mytopic	hash:fc83cb1e	protocol:WebSocket
Recv:	[275]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614181904617985, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614181529671648, 4000]	topic:mytopic	hash:b6225afc	protocol:WebSocket
Recv:	[276]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614182146684960, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614181786355569, 4000]	topic:mytopic	hash:033014b9	protocol:WebSocket
Recv:	[277]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614182404165863, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614182026586673, 4000]	topic:mytopic	hash:02acd092	protocol:WebSocket
Recv:	[278]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614182641449405, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614182284459699, 4000]	topic:mytopic	hash:0eb8fdee	protocol:WebSocket
Recv:	[279]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614182880232151, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614182528298256, 4000]	topic:mytopic	hash:b561eb3d	protocol:WebSocket
Recv:	[280]	receiver_addr:34.105.5.25	[recv_time, size]:[1757614183135161128, 4073]	sender_addr:34.182.119.107	[send_time, size]:[1757614182764241581, 4000]	topic:mytopic	hash:7b5c83d3	protocol:WebSocket
```


