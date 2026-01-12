.PHONY: up down reset logs api web

up:
	docker compose up -d

down:
	docker compose down

reset:
	docker compose down -v
	docker compose up -d

logs:
	docker compose logs -f

api:
	cd api && export REDIS_URL=redis://localhost:6379/0 && bin/rails s -p 3001

worker:
	cd api && export REDIS_URL=redis://localhost:6379/0 && bundle exec sidekiq
