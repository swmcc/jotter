APP_NAME=jotter
RAILS_ENV ?= development

GREEN := $(shell tput -Txterm setaf 2)
RESET := $(shell tput -Txterm sgr0)

.DEFAULT_GOAL := help

# -----------------------------
# 🧩 Local Development
# -----------------------------

local.run: ## Run the Rails app (with bin/dev)
	@echo "$(GREEN)==> Running $(APP_NAME) in $(RAILS_ENV)...$(RESET)"
	bin/dev

local.setup: ## Install gems, setup db and tailwind, seed
	@echo "$(GREEN)==> Setting up $(APP_NAME)...$(RESET)"
	bundle install
	bin/rails db:create
	bin/rails db:migrate
	bin/rails db:seed
	bin/dev

local.install: ## Just install dependencies
	bundle install

local.db.create: ## Create the database
	bin/rails db:create

local.db.drop: ## Drop the database
	bin/rails db:drop

local.db.migrate: ## Run database migrations
	bin/rails db:migrate

local.db.seed: ## Seed the database
	bin/rails db:seed

local.db.reset: ## Reset the database (drop, create, migrate, seed)
	bin/rails db:reset

local.test: ## Run RSpec tests
	bundle exec rspec

console: ## Start Rails console
	bin/rails console

lint: ## Run RuboCop linting
	bundle exec rubocop

lint.fix: ## Auto-fix RuboCop issues
	bundle exec rubocop -A

local.brakeman: ## Run Brakeman static security analysis
	bin/brakeman --exit-on-warn --no-pager

local.rubocop:
	rubocop -A

# -----------------------------
# 🌐 Cypress End-to-End Tests
# -----------------------------

cypress.open: ## Open Cypress interactive GUI
	@echo "$(GREEN)==> Opening Cypress GUI...$(RESET)"
	npm run cypress:open

cypress.run: ## Run Cypress tests headlessly
	@echo "$(GREEN)==> Running Cypress tests headlessly...$(RESET)"
	npm run cypress:run

cypress.clean: ## Remove old Cypress screenshots and videos
	@echo "$(GREEN)==> Cleaning Cypress artifacts...$(RESET)"
	rm -rf cypress/videos/* cypress/screenshots/* || true

cypress.all: cypress.clean cypress.run ## Clean and run Cypress tests
	@echo "$(GREEN)==> Cleaned and ran all Cypress tests.$(RESET)"

# -----------------------------
# 🧰 Meta
# -----------------------------

help: ## Show all available make targets
	@echo "$(GREEN)Available targets:$(RESET)"
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-25s %s\n", $$1, $$2}'
