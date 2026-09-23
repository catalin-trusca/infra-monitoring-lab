.PHONY: up down restart ps logs validate reload-prometheus test-alert traffic stress

up:
	./scripts/render-alertmanager.sh && docker compose up -d
down:
	docker compose down
restart:
	sudo systemctl reload monitoring-stack
ps:
	docker compose ps
logs:
	docker compose logs -f --tail=100
validate:
	./scripts/validate.sh
reload-prometheus:
	curl -s -XPOST http://127.0.0.1:9090/-/reload && echo reloaded
test-alert:
	./scripts/test-alert.sh critical
traffic:
	./scripts/generate-traffic.sh 600
stress:  # ~12 min of full CPU -> HostHighCpuUsage fires after 10 min
	docker run --rm --name stress alexeiled/stress-ng --cpu 0 --timeout 720s --metrics-brief
