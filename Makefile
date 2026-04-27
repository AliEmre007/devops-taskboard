.RECIPEPREFIX := >

.PHONY: bootstrap test build deploy rollback backup logs health structure status clean-help

bootstrap:
> ./scripts/bootstrap.sh

test:
> ./scripts/test.sh

build:
> ./scripts/build.sh

deploy:
> ./scripts/deploy.sh

rollback:
> ./scripts/rollback.sh

backup:
> ./scripts/backup-db.sh

logs:
> ./scripts/logs.sh

health:
> ./scripts/healthcheck.sh

structure:
> tree -a -I ".git|node_modules"

status:
> git status

clean-help:
> echo "This project does not have a clean command yet."
> echo "Later, clean will remove Docker containers, volumes, and generated files."
