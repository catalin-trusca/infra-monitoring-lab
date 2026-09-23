# LogQL queries used in the lab

| Purpose | Query |
|---|---|
| All logs of one container | `{container="webapp"}` |
| Full-text search across containers | `{job="docker"} \|= "error"` |
| Errors only, case-insensitive | `{job="docker"} \|~ "(?i)error\|exception"` |
| Parse nginx access log | `{container="webapp"} \| pattern "<ip> - <_> [<_>] \"<method> <path> <_>\" <status> <_>"` |
| Requests per status code | `sum by (status) (count_over_time({container="webapp"} \| pattern ... [1m]))` |
| 5xx ratio (used by Loki ruler alert) | `sum(rate({container="webapp"} \| pattern ... \| status >= 500 [5m])) / sum(rate({container="webapp"}[5m]))` |
| Top 5 requested paths | `topk(5, sum by (path) (count_over_time({container="webapp"} \| pattern ... [1h])))` |
| Failed SSH logins | `{job="varlogs", filename="/var/log/auth.log"} \|~ "Failed password\|Invalid user"` |
| Failed SSH logins per source IP | `sum by (ip) (count_over_time({filename="/var/log/auth.log"} \|~ "Failed password" \| regexp "from (?P<ip>\\S+)" [1h]))` |
| Firewall blocks per source IP | `sum by (src) (count_over_time({filename="/var/log/ufw.log"} \|= "UFW BLOCK" \| regexp "SRC=(?P<src>\\S+)" [1h]))` |
| Journal errors for a unit | `{job="systemd-journal", unit="docker.service", level=~"err\|crit"}` |
| Healthcheck failures (logfmt) | `{job="monitoring-lab"} \| logfmt \| status="FAIL"` |
| Log volume per container | `sum by (container) (bytes_over_time({job="docker"}[5m]))` |

Label design: only low-cardinality labels are indexed (`job`, `container`, `service`, `stream`, `unit`, `level`, `host`).
High-cardinality values (status code, IP, path) are extracted at query time with `pattern`/`regexp`/`logfmt`,
which keeps the Loki index small.
