*filebeat-docker-socket-leak*

# Summary

Filebeat (as of 6.8.3 and 7.4.1) seems to have a file descriptor leak talking to the Docker daemon socket (best guess). If you run a lot of short lived containers, harvesters will start and stop as designed, but the open file handles count will increase over time.

It seems to be roughly 2~ file handles per container started, so if you set `nofile` to 1024 (soft) / 4096 (hard), and start 512~ containers you will have hit the limit.

# Reproducing

You will need a Docker daemon available/installed (tested on Linux). Then run:

```
./test.sh 6
```

which will test on Filebeat 6.x (using the `docker` input). Or:

```
./test.sh 7
```

which will test on Filebeat 7.x (using the `container` input).

# Example output

Look at the file handles in the output:

```
...
"handles":{"limit":{"hard":4096,"soft":1024},"open":913}
...
"handles":{"limit":{"hard":4096,"soft":1024},"open":971}
```

Rest of the output:

```
filebeat_1  | 2019-10-29T22:37:28.374Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:37:28.374Z	INFO	input/input.go:167	Stopping Input: 4878653136224074224
filebeat_1  | 2019-10-29T22:37:29.248Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/1478e8ba610908a3ded709fd0831221d17a3806bb7e0861b7fcd528ab3099c1d/*.log]
filebeat_1  | 2019-10-29T22:37:29.248Z	INFO	input/input.go:114	Starting input of type: docker; ID: 12932089691039892554 
filebeat_1  | 2019-10-29T22:37:29.248Z	INFO	log/harvester.go:255	Harvester started for file: /var/lib/docker/containers/1478e8ba610908a3ded709fd0831221d17a3806bb7e0861b7fcd528ab3099c1d/1478e8ba610908a3ded709fd0831221d17a3806bb7e0861b7fcd528ab3099c1d-json.log
filebeat_1  | 2019-10-29T22:37:29.283Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/b8bb04da22952934757b1a165107ab2455b239dcda889c63a65ff98a67b7d1af/b8bb04da22952934757b1a165107ab2455b239dcda889c63a65ff98a67b7d1af-json.log. Closing because close_removed is enabled.
filebeat_1  | 2019-10-29T22:37:29.293Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:37:29.293Z	INFO	input/input.go:167	Stopping Input: 9717884665371582304
filebeat_1  | 2019-10-29T22:37:29.719Z	INFO	[monitoring]	log/log.go:144	Non-zero metrics in the last 30s	{"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":19280,"time":{"ms":1918}},"total":{"ticks":43940,"time":{"ms":4989},"value":43940},"user":{"ticks":24660,"time":{"ms":3071}}},"handles":{"limit":{"hard":4096,"soft":1024},"open":913},"info":{"ephemeral_id":"fd067e21-2284-4079-b379-8942fb5211ba","uptime":{"ms":450032}},"memstats":{"gc_next":88251968,"memory_alloc":66735864,"memory_total":2102395200,"rss":5607424}},"filebeat":{"events":{"added":303,"done":303},"harvester":{"closed":30,"open_files":3,"running":3,"started":30}},"libbeat":{"config":{"module":{"running":0}},"output":{"events":{"acked":213,"batches":30,"total":213},"read":{"bytes":210},"write":{"bytes":337258}},"pipeline":{"clients":32,"events":{"active":6,"filtered":90,"published":213,"total":303},"queue":{"acked":213}}},"registrar":{"states":{"cleanup":30,"current":7,"update":303},"writes":{"success":120,"total":120}},"system":{"load":{"1":3.49,"15":3.86,"5":4.36,"norm":{"1":0.8725,"15":0.965,"5":1.09}}}}}}
filebeat_1  | 2019-10-29T22:37:30.252Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/1478e8ba610908a3ded709fd0831221d17a3806bb7e0861b7fcd528ab3099c1d/1478e8ba610908a3ded709fd0831221d17a3806bb7e0861b7fcd528ab3099c1d-json.log. Closing because close_removed is enabled.
filebeat_1  | 2019-10-29T22:37:30.288Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/2cf7b571733ac0dc84b5066c96952a52b9049ac0c24f4af0ce47693d5df64f73/*.log]
filebeat_1  | 2019-10-29T22:37:30.288Z	INFO	input/input.go:114	Starting input of type: docker; ID: 10848902023602075598 
filebeat_1  | 2019-10-29T22:37:30.288Z	INFO	log/harvester.go:255	Harvester started for file: /var/lib/docker/containers/2cf7b571733ac0dc84b5066c96952a52b9049ac0c24f4af0ce47693d5df64f73/2cf7b571733ac0dc84b5066c96952a52b9049ac0c24f4af0ce47693d5df64f73-json.log
filebeat_1  | 2019-10-29T22:37:30.337Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:37:30.337Z	INFO	input/input.go:167	Stopping Input: 10100708974694274441
filebeat_1  | 2019-10-29T22:37:31.245Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/d611f023f78aee1d0cd15cd86a054ffe13c27a974cbe03fba576e52f18e40951/*.log]
filebeat_1  | 2019-10-29T22:37:31.245Z	INFO	input/input.go:114	Starting input of type: docker; ID: 15652091254810497769 
filebeat_1  | 2019-10-29T22:37:31.245Z	INFO	log/harvester.go:255	Harvester started for file: /var/lib/docker/containers/d611f023f78aee1d0cd15cd86a054ffe13c27a974cbe03fba576e52f18e40951/d611f023f78aee1d0cd15cd86a054ffe13c27a974cbe03fba576e52f18e40951-json.log

...<stopping and starting a few more containers between stats output>...

filebeat_1  | 2019-10-29T22:37:59.723Z	INFO	[monitoring]	log/log.go:144	Non-zero metrics in the last 30s	{"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":21140,"time":{"ms":1866}},"total":{"ticks":49090,"time":{"ms":5146},"value":49090},"user":{"ticks":27950,"time":{"ms":3280}}},"handles":{"limit":{"hard":4096,"soft":1024},"open":971},"info":{"ephemeral_id":"fd067e21-2284-4079-b379-8942fb5211ba","uptime":{"ms":480031}},"memstats":{"gc_next":94563376,"memory_alloc":69158984,"memory_total":2351778912,"rss":7344128}},"filebeat":{"events":{"added":293,"done":293},"harvester":{"closed":29,"open_files":3,"running":3,"started":29}},"libbeat":{"config":{"module":{"running":0}},"output":{"events":{"acked":206,"batches":30,"total":206},"read":{"bytes":210},"write":{"bytes":326216}},"pipeline":{"clients":31,"events":{"active":6,"filtered":87,"published":206,"total":293},"queue":{"acked":206}}},"registrar":{"states":{"cleanup":29,"current":6,"update":293},"writes":{"success":117,"total":117}},"system":{"load":{"1":4.8,"15":3.95,"5":4.57,"norm":{"1":1.2,"15":0.9875,"5":1.1425}}}}}}
filebeat_1  | 2019-10-29T22:38:00.135Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/84be390e4994512274249d850a4882a4bbac6a7fc01802df25e69629d66ba523/84be390e4994512274249d850a4882a4bbac6a7fc01802df25e69629d66ba523-json.log. Closing because close_removed is enabled.
filebeat_1  | 2019-10-29T22:38:00.154Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/c67d5e0367c4a466d88bd214558fff7356c3fedb5cedc37164a2f245eb133d8e/*.log]
filebeat_1  | 2019-10-29T22:38:00.154Z	INFO	input/input.go:114	Starting input of type: docker; ID: 13806190548165761361 
filebeat_1  | 2019-10-29T22:38:00.155Z	INFO	log/harvester.go:255	Harvester started for file: /var/lib/docker/containers/c67d5e0367c4a466d88bd214558fff7356c3fedb5cedc37164a2f245eb133d8e/c67d5e0367c4a466d88bd214558fff7356c3fedb5cedc37164a2f245eb133d8e-json.log
filebeat_1  | 2019-10-29T22:38:00.348Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:00.348Z	INFO	input/input.go:167	Stopping Input: 10848902023602075598
filebeat_1  | 2019-10-29T22:38:01.155Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/c67d5e0367c4a466d88bd214558fff7356c3fedb5cedc37164a2f245eb133d8e/c67d5e0367c4a466d88bd214558fff7356c3fedb5cedc37164a2f245eb133d8e-json.log. Closing because close_removed is enabled.

...<stopping and starting a few more containers between stats output>...

filebeat_1  | 2019-10-29T22:38:23.016Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:23.016Z	INFO	input/input.go:167	Stopping Input: 5030897693874860188
filebeat_1  | 2019-10-29T22:38:23.478Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/27f09180a414017c4fb5350c7e9ae805a6ef6282623b95b1bd59188ab90c0019/*.log]
filebeat_1  | 2019-10-29T22:38:23.478Z	INFO	input/input.go:114	Starting input of type: docker; ID: 8615692364983691557 
filebeat_1  | 2019-10-29T22:38:23.479Z	INFO	log/harvester.go:255	Harvester started for file: /var/lib/docker/containers/27f09180a414017c4fb5350c7e9ae805a6ef6282623b95b1bd59188ab90c0019/27f09180a414017c4fb5350c7e9ae805a6ef6282623b95b1bd59188ab90c0019-json.log
filebeat_1  | 2019-10-29T22:38:23.524Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/ffb82d0951b0252e4d1d3cef0c3437cbbd535993a278e9fae033c935838fccf4/ffb82d0951b0252e4d1d3cef0c3437cbbd535993a278e9fae033c935838fccf4-json.log. Closing because close_removed is enabled.
filebeat_1  | 2019-10-29T22:38:24.103Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:24.103Z	INFO	input/input.go:167	Stopping Input: 17570687079424565250
filebeat_1  | 2019-10-29T22:38:24.469Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/4e751747b089c2aa332db5aef2916c566ffe86d69005140fd8a17778836a8dea/*.log]
filebeat_1  | 2019-10-29T22:38:24.469Z	INFO	input/input.go:114	Starting input of type: docker; ID: 2435843721686406388 
filebeat_1  | 2019-10-29T22:38:24.470Z	INFO	log/harvester.go:255	Harvester started for file: /var/lib/docker/containers/4e751747b089c2aa332db5aef2916c566ffe86d69005140fd8a17778836a8dea/4e751747b089c2aa332db5aef2916c566ffe86d69005140fd8a17778836a8dea-json.log
filebeat_1  | 2019-10-29T22:38:24.480Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/27f09180a414017c4fb5350c7e9ae805a6ef6282623b95b1bd59188ab90c0019/27f09180a414017c4fb5350c7e9ae805a6ef6282623b95b1bd59188ab90c0019-json.log. Closing because close_removed is enabled.
filebeat_1  | 2019-10-29T22:38:25.153Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:25.153Z	INFO	input/input.go:167	Stopping Input: 14577039803959008024
filebeat_1  | 2019-10-29T22:38:25.412Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/224d8a0961f27e48e39e813a8820eb9936b722bdbf70aeffa13187015742211f/*.log]
filebeat_1  | 2019-10-29T22:38:25.413Z	INFO	input/input.go:114	Starting input of type: docker; ID: 14185000190077366165 
filebeat_1  | 2019-10-29T22:38:25.413Z	INFO	log/harvester.go:255	Harvester started for file: /var/lib/docker/containers/224d8a0961f27e48e39e813a8820eb9936b722bdbf70aeffa13187015742211f/224d8a0961f27e48e39e813a8820eb9936b722bdbf70aeffa13187015742211f-json.log
filebeat_1  | 2019-10-29T22:38:25.471Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/4e751747b089c2aa332db5aef2916c566ffe86d69005140fd8a17778836a8dea/4e751747b089c2aa332db5aef2916c566ffe86d69005140fd8a17778836a8dea-json.log. Closing because close_removed is enabled.
filebeat_1  | 2019-10-29T22:38:26.156Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:26.156Z	INFO	input/input.go:167	Stopping Input: 3876012511610202226
filebeat_1  | 2019-10-29T22:38:26.413Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/224d8a0961f27e48e39e813a8820eb9936b722bdbf70aeffa13187015742211f/224d8a0961f27e48e39e813a8820eb9936b722bdbf70aeffa13187015742211f-json.log. Closing because close_removed is enabled.
filebeat_1  | 2019-10-29T22:38:26.421Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/ac2b1990a7d59764122451c1eee2566a90fce54578498c589e2a9e36e619f893/*.log]
filebeat_1  | 2019-10-29T22:38:26.421Z	INFO	input/input.go:114	Starting input of type: docker; ID: 7751588425117266843 
filebeat_1  | 2019-10-29T22:38:26.421Z	INFO	log/harvester.go:255	Harvester started for file: /var/lib/docker/containers/ac2b1990a7d59764122451c1eee2566a90fce54578498c589e2a9e36e619f893/ac2b1990a7d59764122451c1eee2566a90fce54578498c589e2a9e36e619f893-json.log
filebeat_1  | 2019-10-29T22:38:26.426Z	ERROR	docker/watcher.go:251	Error getting container info: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.30/containers/json?filters=%7B%22id%22%3A%7B%22ac2b1990a7d59764122451c1eee2566a90fce54578498c589e2a9e36e619f893%22%3Atrue%7D%7D&limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:27.207Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:27.207Z	INFO	input/input.go:167	Stopping Input: 14303694852835654588
filebeat_1  | 2019-10-29T22:38:27.265Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:27.422Z	INFO	log/harvester.go:272	File was removed: /var/lib/docker/containers/ac2b1990a7d59764122451c1eee2566a90fce54578498c589e2a9e36e619f893/ac2b1990a7d59764122451c1eee2566a90fce54578498c589e2a9e36e619f893-json.log. Closing because close_removed is enabled.
filebeat_1  | 2019-10-29T22:38:28.211Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:28.211Z	INFO	input/input.go:167	Stopping Input: 16772454500976752441
filebeat_1  | 2019-10-29T22:38:28.213Z	INFO	log/input.go:148	Configured paths: [/var/lib/docker/containers/3282b182a169f999029797446891d3d7b32e31c3009c03908d49b1a9a978fc7f/*.log]
filebeat_1  | 2019-10-29T22:38:28.213Z	INFO	input/input.go:114	Starting input of type: docker; ID: 5972515863442680542 
filebeat_1  | 2019-10-29T22:38:28.288Z	ERROR	docker/watcher.go:251	Error getting container info: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.30/containers/json?filters=%7B%22id%22%3A%7B%22e7018ec0eba7bf50fb6f628a97fca40da0143505e6a38d137a43c1f4c9f49866%22%3Atrue%7D%7D&limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:28.391Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:28.477Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:28.477Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:28.570Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:28.570Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:29.202Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:29.202Z	INFO	input/input.go:167	Stopping Input: 12684145137252119474
filebeat_1  | 2019-10-29T22:38:29.202Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:29.493Z	ERROR	docker/watcher.go:251	Error getting container info: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.30/containers/json?filters=%7B%22id%22%3A%7B%2232e469245cf18cc905534e049bbaa29a7a0c699b65d583487497642afe405743%22%3Atrue%7D%7D&limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:29.499Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:29.499Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:29.571Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:29.571Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:29.582Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:29.582Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:29.709Z	ERROR	instance/metrics.go:91	Error while getting memory usage: error retrieving process stats: cannot find matching process for pid=1
filebeat_1  | 2019-10-29T22:38:29.709Z	ERROR	instance/metrics.go:135	Error retrieving CPU percentages: error retrieving process stats: cannot find matching process for pid=1
filebeat_1  | 2019-10-29T22:38:29.709Z	ERROR	instance/metrics_file_descriptors.go:39	Error while retrieving FD information: error retrieving process stats: cannot find matching process for pid=1
filebeat_1  | 2019-10-29T22:38:29.709Z	INFO	[monitoring]	log/log.go:144	Non-zero metrics in the last 30s	{"monitoring": {"metrics": {"beat":{"info":{"ephemeral_id":"fd067e21-2284-4079-b379-8942fb5211ba","uptime":{"ms":510025}},"memstats":{"gc_next":97922640,"memory_alloc":78217680,"memory_total":2623186072}},"filebeat":{"events":{"active":2,"added":294,"done":292},"harvester":{"closed":28,"open_files":2,"running":2,"started":27}},"libbeat":{"config":{"module":{"running":0}},"output":{"events":{"acked":207,"batches":30,"total":207},"read":{"bytes":210},"write":{"bytes":330249}},"pipeline":{"clients":30,"events":{"active":8,"filtered":85,"published":209,"total":294},"queue":{"acked":207}}},"registrar":{"states":{"cleanup":30,"current":3,"update":292},"writes":{"fail":4,"success":111,"total":115}},"system":{"load":{"1":0,"15":0,"5":0,"norm":{"1":0,"15":0,"5":0}}}}}}
filebeat_1  | 2019-10-29T22:38:30.208Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:30.208Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:30.208Z	INFO	input/input.go:167	Stopping Input: 13806190548165761361
filebeat_1  | 2019-10-29T22:38:30.208Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:30.417Z	ERROR	docker/watcher.go:251	Error getting container info: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.30/containers/json?filters=%7B%22id%22%3A%7B%228a360617939b84ec11143649f59a4d5834f1415e0c349883850879368b84532f%22%3Atrue%7D%7D&limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:30.469Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:30.470Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:30.470Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:30.525Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:30.525Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:30.575Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:30.575Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:31.279Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:31.279Z	INFO	input/input.go:167	Stopping Input: 8721529453547272764
filebeat_1  | 2019-10-29T22:38:31.279Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:31.280Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:31.280Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:31.345Z	ERROR	docker/watcher.go:251	Error getting container info: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.30/containers/json?filters=%7B%22id%22%3A%7B%223bdb1ba7121ee2fa6d8c07d2afa0de6165866598d5ebea626d3406cf81117ba5%22%3Atrue%7D%7D&limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:31.457Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:31.490Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:31.495Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:31.499Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:31.546Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:31.546Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:31.577Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:31.577Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:32.251Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.251Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.251Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.251Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.251Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:32.251Z	INFO	input/input.go:167	Stopping Input: 7892185611477803783
filebeat_1  | 2019-10-29T22:38:32.362Z	ERROR	docker/watcher.go:251	Error getting container info: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.30/containers/json?filters=%7B%22id%22%3A%7B%2237cd8635675fe1b21c00fa9b3dc93ec279eca65f1a237c066bf80708a35622e6%22%3Atrue%7D%7D&limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.402Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.402Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.403Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.403Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.403Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:32.524Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:32.524Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:32.578Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:32.578Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:33.259Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.259Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.259Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.259Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.259Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.259Z	INFO	input/input.go:149	input ticker stopped
filebeat_1  | 2019-10-29T22:38:33.259Z	INFO	input/input.go:167	Stopping Input: 10110384886433882202
filebeat_1  | 2019-10-29T22:38:33.350Z	ERROR	docker/watcher.go:251	Error getting container info: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.30/containers/json?filters=%7B%22id%22%3A%7B%2254d03e82afd8e594321cbc51c68f01708b1e1f44eb3f8191c89105bff3e90188%22%3Atrue%7D%7D&limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.479Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:33.479Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...
filebeat_1  | 2019-10-29T22:38:33.502Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.503Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.503Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.503Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.504Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.504Z	ERROR	[autodiscover]	cfgfile/list.go:96	Error creating runner from config: error during connect: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.22/containers/json?limit=0: dial unix /var/run/docker.sock: socket: too many open files
filebeat_1  | 2019-10-29T22:38:33.579Z	ERROR	registrar/registrar.go:405	Failed to create tempfile (/usr/share/filebeat/data/registry.new) for writing: open /usr/share/filebeat/data/registry.new: too many open files
filebeat_1  | 2019-10-29T22:38:33.579Z	ERROR	registrar/registrar.go:363	Writing of registry returned error: open /usr/share/filebeat/data/registry.new: too many open files. Continuing...

```
